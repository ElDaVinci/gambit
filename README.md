# Gambit — Dice Chess

Chess with real chess rules, plus one twist: **captures are not automatic**. When you try
to take a piece you fight for it — attacker rolls 1d6, defender rolls 1d6, ties re-roll,
higher wins. Lose the roll and your attacking piece is gone; the defender holds the square.
Inspired by the battle resolution in Risk (Risiko).

## Play it

**→ https://eldavinci.github.io/gambit/**

Public, no sign-in, works on phones. Installs to your home screen (see below).

You can also just double-click [`index.html`](index.html) — it's a single self-contained
file that runs straight off disk, no server needed.

## The v1 ruleset (short version)

Standard chess for everything except captures. A capture is a **battle**: each side rolls
and keeps its highest die, re-roll ties. Win → normal capture. Lose → **your attacking
piece is removed**, defender stays. **How many dice you roll to attack depends on the
piece — Queen 3, Rook/Bishop/Knight 2, Pawn 1 — which is 79%, 69% and 50% to the attacker.
The defender always rolls one die, whatever it is**, so extra dice make a piece better at
taking, never harder to kill. The King never rolls (classic check/checkmate; King captures
auto-succeed).
While your King is in check you keep moving — risking more pieces if you choose — until
it's safe or it's checkmate. En passant is a battle; castling isn't; a capturing promotion
battles first and promotes only on a win.

Full ruleset: [`docs/Battle Mechanics.md`](docs/Battle%20Mechanics.md).

## Install it as an app

Gambit is a PWA, so it installs to a phone or desktop home screen with its own icon,
opens without browser chrome, and runs offline.

- **iPhone / iPad:** open the site in **Safari** → Share → *Add to Home Screen*.
  (Safari only — Chrome on iOS cannot install web apps.)
- **Android:** Chrome offers *Install app*, or use ⋮ → *Add to Home screen*.
- **Desktop Chrome / Edge:** an install icon appears at the right of the address bar.

Offline support comes from [`sw.js`](sw.js), which caches the app shell. Navigations are
network-first, so a new version is picked up as soon as you are online; other assets are
cache-first for instant launches. **Bump `CACHE` in `sw.js` whenever you ship a change** —
that string is the cache-busting key.

## Repo layout

| Path | What |
|---|---|
| `index.html` | The game. Standalone — also runs by double-clicking, no server needed. |
| `manifest.webmanifest`, `sw.js`, `icons/` | PWA plumbing: install metadata, offline cache, app icons. |
| `.nojekyll` | Stops GitHub Pages running Jekyll, which would otherwise ignore paths beginning with `_`. |
| `gambit.artifact.html` | Generated copy for publishing as a Claude Artifact. Never edit by hand — run `bash tools/build-artifact.sh`. |
| `archive/` | Frozen, still-playable snapshots of earlier rulesets. Never edit — see below. |
| `tools/` | Dev scripts, not part of the app. See below. |
| `docs/` | Obsidian vault — design, the locked ruleset, decisions, roadmap. Open `docs/` as a vault; start at `docs/Home.md`. |
| `src/`, `assets/` | Reserved; unused so far. |

### tools/

| Script | Purpose |
|---|---|
| `serve.ps1` | Serves the folder at `http://localhost:8100`. Needed because service workers refuse to run from `file://`. Run: `powershell -File tools/serve.ps1` |
| `make-icons.ps1` | Regenerates `icons/*.png` via System.Drawing. Only needed if the icon design changes. |
| `build-artifact.sh` | Rebuilds `gambit.artifact.html` from `index.html`. Run after every change to the game. |

## Archived rulesets

Each time the core mechanic changes, the previous one is frozen here — as a **playable
page**, not just a commit — so two mechanics can be compared side by side on a phone.

| Ruleset | Play it | Git tag |
|---|---|---|
| **v21 — dice ladder** (Queen 3, Rook/Bishop/Knight 2, Pawn 1; defender always 1) | [`/archive/v21-dice-ladder/`](https://eldavinci.github.io/gambit/archive/v21-dice-ladder/) | `v21-dice-ladder` |

Each archive **installs as its own app**, with its own manifest, its own service worker
scoped to its folder, and its own icon on a different-coloured ground — so two Gambits on
a home screen are told apart at a glance. Regenerate a variant icon with
`powershell -File tools/make-icons.ps1 -OutDir <dir> -Bg '#4A3B2A'`.

Rules for the archive, so a snapshot stays trustworthy:

- **Never edit the game inside `archive/`.** It is a record of how it actually played.
- The live `sw.js` skips any path containing `/archive/`, and each archive's own worker is
  scoped to its own folder. Neither can serve the other's files — otherwise the live
  worker's offline fallback would hand back the *current* `index.html` at an archive URL
  and quietly show the wrong game.
- To restore one as the live game: `git checkout <tag> -- index.html`.

## Playing the computer

Turn on **Play against the computer** in the Table panel. Four strengths (Easy, Medium,
Hard, Master) and you can hand either colour to the bot.

The engine is an **expectiminimax** search, not plain minimax — that matters here. Every
capture is a chance node weighted by *that matchup's* real odds, so the bot plays the
expected value of an attack (`EV = p·victim − (1−p)·attacker`, where `p` comes from the
attacker's dice count). In practice it only starts a fight worth losing: it will happily
throw a pawn at your queen and will not throw its queen at your pawn. Because `p` is
derived from the dice table rather than hardcoded, retuning the dice retunes the bot
automatically. Details and benchmarks in [`docs/Roadmap.md`](docs/Roadmap.md).

## Status

**Playable**, hotseat or vs. computer. Chess engine is perft-verified (perft 1–4 and
the Kiwipete position match standard chess exactly). The dice ladder (Queen 3 / minor +
rook 2 / pawn 1) is the current balance experiment and the main thing to playtest —
attacking is now favoured for everything except pawns, so material is far less "sticky"
than it was under the original flat 50/50. See [`docs/Roadmap.md`](docs/Roadmap.md).

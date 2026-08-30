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

Standard chess for everything except captures. A capture is a **battle**: 1d6 vs 1d6,
re-roll ties, 50/50. Win → normal capture. Lose → **your attacking piece is removed**,
defender stays. The King never rolls (classic check/checkmate; King captures auto-succeed).
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
| `tools/` | Dev scripts, not part of the app. See below. |
| `docs/` | Obsidian vault — design, the locked ruleset, decisions, roadmap. Open `docs/` as a vault; start at `docs/Home.md`. |
| `src/`, `assets/` | Reserved; unused so far. |

### tools/

| Script | Purpose |
|---|---|
| `serve.ps1` | Serves the folder at `http://localhost:8100`. Needed because service workers refuse to run from `file://`. Run: `powershell -File tools/serve.ps1` |
| `make-icons.ps1` | Regenerates `icons/*.png` via System.Drawing. Only needed if the icon design changes. |
| `build-artifact.sh` | Rebuilds `gambit.artifact.html` from `index.html`. Run after every change to the game. |

## Playing the computer

Turn on **Play against the computer** in the Table panel. Four strengths (Easy, Medium,
Hard, Master) and you can hand either colour to the bot.

The engine is an **expectiminimax** search, not plain minimax — that matters here. Every
capture is a chance node with two equally likely outcomes, so the bot plays the *expected*
value of an attack (`EV = ½·victim − ½·attacker`). In practice it only starts a fight it
is worth losing: it will happily throw a pawn at your queen and will not throw its queen
at your pawn. Details and benchmarks in [`docs/Roadmap.md`](docs/Roadmap.md).

## Status

**v1 playable**, hotseat or vs. computer. Chess engine is perft-verified (perft 1–4 and
the Kiwipete position match standard chess exactly). Next up is playtesting the feel of
50/50-on-every-capture and tuning from there — see [`docs/Roadmap.md`](docs/Roadmap.md).

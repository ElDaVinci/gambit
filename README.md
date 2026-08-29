# Gambit — Dice Chess

Chess with real chess rules, plus one twist: **captures are not automatic**. When you try
to take a piece you fight for it — attacker rolls 1d6, defender rolls 1d6, ties re-roll,
higher wins. Lose the roll and your attacking piece is gone; the defender holds the square.
Inspired by the battle resolution in Risk (Risiko).

## Play it

- **Locally:** double-click [`index.html`](index.html) — it's a single self-contained file,
  no install, works in any modern browser on desktop or phone.
- **Shared link:** published as a private Artifact (opens on phones). See the chat where it
  was created for the URL, or `/artifacts` in Claude Code.

## The v1 ruleset (short version)

Standard chess for everything except captures. A capture is a **battle**: 1d6 vs 1d6,
re-roll ties, 50/50. Win → normal capture. Lose → **your attacking piece is removed**,
defender stays. The King never rolls (classic check/checkmate; King captures auto-succeed).
While your King is in check you keep moving — risking more pieces if you choose — until
it's safe or it's checkmate. En passant is a battle; castling isn't; a capturing promotion
battles first and promotes only on a win.

Full ruleset: [`docs/Battle Mechanics.md`](docs/Battle%20Mechanics.md).

## Repo layout

| Path | What |
|---|---|
| `index.html` | The game. Standalone, double-click to play. |
| `gambit.artifact.html` | Body-only copy of `index.html` for publishing as an Artifact. Regenerate from `index.html` when it changes (strip the `<!doctype>/<html>/<head>/<body>` wrapper). |
| `docs/` | Obsidian vault — design, the locked ruleset, decisions, roadmap. Open `docs/` as a vault; start at `docs/Home.md`. |
| `src/`, `assets/` | Reserved; unused so far. |

## Status

**v1 playable.** Two-player hotseat. Chess engine is perft-verified (perft 1–4 and the
Kiwipete position match standard chess exactly). Next up is playtesting the feel of
50/50-on-every-capture and tuning from there — see [`docs/Roadmap.md`](docs/Roadmap.md).

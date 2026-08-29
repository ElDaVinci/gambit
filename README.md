# Dice Chess (working title)

Chess with real chess rules — plus one twist: **captures are not automatic**. When you
try to take a piece, you fight for it. Dice decide who wins the square. Inspired by the
battle resolution in Risk (Risiko).

## Status

Early design. Nothing is built yet. Mechanics are still being worked out — see the
design vault in [`docs/`](docs/).

## Repo layout

| Path        | What                                                              |
|-------------|------------------------------------------------------------------|
| `docs/`     | Obsidian vault — game design, battle mechanics, open questions.   |
| `src/`      | Application code (not started).                                   |
| `assets/`   | Art, icons, sounds.                                               |

## Opening the design notes

Open Obsidian → "Open folder as vault" → select `dice-chess/docs`.
Start at [`docs/Home.md`](docs/Home.md).

## Build plan

This machine has no Node.js or Python installed, so the first playable version targets a
**single self-contained HTML file** (vanilla JS + CSS, zero build step) that runs by
double-clicking it in a browser. If we later want a component framework, we install
Node.js and move to Vite. See [`docs/Roadmap.md`](docs/Roadmap.md).

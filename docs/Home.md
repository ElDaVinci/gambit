# Dice Chess — Design Vault

One twist on chess: **you have to win a fight to capture a piece.** Movement and all
other chess rules stay exactly as they are. When a capture is attempted, both players
roll dice; higher result takes the square.

## Map of notes

- [[Game Design]] — the pitch, design pillars, what stays classic vs. what changes.
- [[Battle Mechanics]] — how a capture fight is resolved. The core system.
- [[Open Questions]] — decisions we still need to make together. **Read this next.**
- [[Roadmap]] — build phases and the tech decision.

## The one-paragraph pitch

It is chess. You develop, you control the centre, you calculate. But every capture is a
gamble whose odds you can read before you commit: a pawn taking a defended knight might
roll 3 dice against 1 and still lose the exchange, leaving your pawn dead and the knight
standing. Strong pieces win most fights they pick; weak pieces attacking up are a
coin-flip you take when the position is worth it. The board becomes a map of odds.

## Current state

Nothing built. Node.js / Python are not installed on this machine — first playable
version is a single self-contained HTML file. See [[Roadmap]].

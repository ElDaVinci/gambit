# Roadmap

## Tech decision

This machine currently has **no Node.js and no Python**. `winget` is available, so Node
*can* be installed on request.

**Prototype target: one self-contained `index.html`** (vanilla JS + CSS, no build, no
dependencies). Rationale:
- Runs instantly by double-clicking — nothing to install.
- Easy to publish as a shareable Artifact link to playtest with others.
- The rules engine (move generation + battle resolution) is a few hundred lines of plain
  JS; a framework buys us little at prototype size.

If the project grows (menus, AI, online play, animations), install Node and migrate to
**Vite + TypeScript**. The rules engine written now carries over unchanged.

## Phase 0 — decisions ✅ when [[Open Questions]] table is filled

## Phase 1 — rules engine (headless)
- Board representation, FEN load/export.
- Legal move generation for all pieces, including check, castling, en passant, promotion.
- Unit tests via known positions / perft counts.
- No UI yet — just a module + a tiny test page.

## Phase 2 — battle system
- `resolveBattle(attacker, defender, context)` → dice, rolls, outcome.
- Probability calculator for the preview (`winChance(attacker, defender, context)`).
- Config object holding every tunable from [[Open Questions]] (ratings, initiative N,
  tie rule, loss outcome, support on/off) so playtesting = editing one object.

## Phase 3 — UI
- Draw the board, pieces (Unicode glyphs first, sprites later), drag or click to move.
- Legal-move highlights.
- Battle preview panel: "Pawn → Knight · you roll 3 · they roll 3 · 44% · on loss: pawn
  falls". Confirm / cancel.
- Dice-roll animation and result log (move list with battle outcomes).

## Phase 4 — polish + playtest
- Hotseat mode complete.
- Run a simulator: N random/greedy games, dump capture-success stats, tune the config.
- Sound, animations, board themes.

## Phase 5 — optional
- Simple AI opponent (material + win-probability-aware search).
- Support-bonus layer.
- Node/Vite migration if warranted.
- Online play.

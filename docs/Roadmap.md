# Roadmap

## Tech decision — DONE

Built as **one self-contained `index.html`** (vanilla JS + CSS, no build, no deps). No
Node/Python needed on this machine. Runs by double-click; also published as a shareable
Artifact so it opens on phones. If the project later grows (AI, online play), install Node
and migrate to Vite + TypeScript — the engine carries over.

## Phase 1 — rules engine ✅ DONE

- 8×8 array board, full legal move generation (sliders, knight, pawn, castling, en
  passant, promotion), attack/check detection, checkmate / stalemate / threefold /
  fifty-move / insufficient material.
- Verified: perft(1..4) = 20 / 400 / 8902 / 197281 and the Kiwipete position
  (perft 1 = 48, perft 2 = 2039) match standard chess exactly.

## Phase 2 — battle system ✅ DONE

- Capture → `battle()`: 1d6 vs 1d6, re-roll ties, 50/50.
- Win → normal capture. Loss → attacker removed via `applyMove(mv, false)`, defender holds.
- Classic King; King captures skip the battle. In-check turns loop until the king is safe
  or no legal move exists (checkmate).
- Matches the [[Battle Mechanics]] worked example (pinned pawn d2xc3) exactly.

## Phase 3 — UI ✅ DONE (v1)

- Responsive board — desktop split / mobile single column, tap to select + move.
- Legal-move dots + capture rings, last-move and check highlights.
- Battle overlay: tumbling dice, visible tie re-rolls, brass "Capture!" / red "Attack
  repelled" verdict, Continue.
- Move log (chess-numbered, ✓/✗ on capture attempts), fallen-piece trays with point
  totals, "last battle" readout.
- Rotate-board-each-turn toggle, light/dark theme toggle, both persisted to localStorage.
- Promotion picker. Game-over panel with reason.

## Phase 4 — next

- **Playtest.** Does the 50/50-everything feel good, or too swingy? Tune from real games.
- Optional simulator: N random/greedy games, dump capture-attempt and game-length stats.
- Undo / takeback (tricky with committed dice — decide the rule first).
- Resolve the open §8 question (in-check speculative captures elsewhere on the board).
- Sound, capture/roll animations polish, board-theme options.
- FEN or PGN-style export/import for sharing positions.

## Phase 5 — optional

- Simple AI opponent (material + expected-value-of-capture search).
- Node/Vite migration if warranted.
- Online play.

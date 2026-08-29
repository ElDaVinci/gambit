# Game Design

## Design pillars

1. **Real chess underneath.** Legal moves, check, castling, en passant, promotion,
   draws — all standard. A strong chess player should still feel at home.
2. **Every capture is a readable gamble.** Before you commit, you can see the dice each
   side will roll and the win probability. No hidden information in the odds.
3. **Risk scales with the mismatch.** Trading like-for-like is close to a coin flip.
   Attacking a much stronger piece is a long shot you take on purpose. Overwhelming
   force is reliable but never 100% guaranteed.
4. **The randomness is bounded.** One bad roll should sting, not lose the game on move 6.
   Mitigation tools (see [[Open Questions]]) keep variance in check.

## What stays exactly like classic chess

- Piece movement and legal-move generation.
- Turn order, one move per turn.
- Castling, en passant, promotion, the 50-move rule, threefold repetition, stalemate.
- Check must be responded to (but see the King question in [[Open Questions]]).

## What changes

- **Captures are resolved by a battle**, not executed automatically. See
  [[Battle Mechanics]].
- A failed capture **still consumes your turn** (you spent the tempo on a failed
  assault). This is the cost that makes attacking a real decision.
- Possible new layer: **support bonuses** — a piece backed by friendly attackers/defenders
  brings extra dice. This is the "many parameters of a real battle" idea. Optional; see
  [[Open Questions]].

## Reference values (starting point)

| Piece  | Classic value | Proposed combat rating |
|--------|---------------|------------------------|
| Pawn   | 1             | 1                      |
| Knight | 3             | 3                      |
| Bishop | 3             | 3                      |
| Rook   | 5             | 4                      |
| Queen  | 9             | 5                      |
| King   | —             | 4 (if King fights at all — see Open Questions) |

Combat rating is compressed relative to classic value so the Queen is not nearly
unbeatable. Exact numbers are tunable once we can simulate games.

## Modes (later)

- Local hotseat (two players, one screen) — first target.
- Vs. a simple AI.
- Online — much later, out of scope for the prototype.

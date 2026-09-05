# Soldiers (v23 — current ruleset)

Standard chess movement. Everything about **capturing** is replaced: a piece is not
a single token that lives or dies on one roll, it is a **unit with a garrison of
soldiers**, and an attack is a single duel between one soldier from each side.

Supersedes [[Battle Mechanics]], which is archived and still playable at
`/archive/v21-dice-ladder/`.

## 1. Garrisons

| Piece | Soldiers |
|---|---|
| Pawn | 4 |
| Knight | 8 |
| Bishop | 8 |
| Rook | 10 |
| Queen | 15 |
| **King** | **20** |

The number is shown in a badge on the top-right corner of the piece. It turns brass
once the unit has taken losses and red on its last soldier. **Damage is permanent** —
there is no healing, and a promoted pawn cannot carry more soldiers than its new rank
allows.

## 2. An attack is one duel

Attacking an enemy piece plays out **one duel and one only**:

1. Each side sends one soldier. The attacker rolls its dice, the defender rolls one.
2. Each keeps its **highest single die**. Higher wins. Ties re-roll.
3. **Exactly one soldier dies — the loser's.**
4. Nothing else happens. Both pieces stay exactly where they were, and the turn ends.

A unit is destroyed only when its **last** soldier falls. At that moment the attacker
advances onto the square, carrying its own remaining garrison with it.

### Attacking dice

| Attacker | Dice | Wins a duel |
|---|---|---|
| **King** | 4 | **84.9 %** |
| **Queen** | 3 | **79.2 %** |
| **Rook / Bishop / Knight** | 2 | **69.4 %** |
| **Pawn** | 1 | **50.0 %** |
| *Any defender* | *1* | — |

The **defender always rolls one die**, whatever piece it is. Extra dice make a unit
better at attacking, never harder to kill.

## 3. The King fights

The King is no longer untouchable. It has the largest garrison (20), attacks with four
dice, and defends with one like everyone else. It can be attacked, worn down, and
killed.

**You lose when your King's last soldier falls. There is no checkmate.**

## 4. What that does to check

Check cannot be a forcing rule any more, and this is a consequence of the duel, not a
preference. A duel removes one soldier, so attacking the checking piece can never clear
the check in a single move — under the old "keep moving until your King is safe" rule
the side to move would attack, still be in check, move again, and never end its turn.

So:

- **One move per turn, always.**
- **Check does not dictate what you move.** Run, block, fight the attacker, or ignore
  it and take the hits — the player's choice, which is the point.
- The King keeps exactly one restriction: it **may not step onto a square the enemy
  attacks**. Attacking *from* its square is fine — that is the "fight" option.
- **Pins no longer bind.** Moving a pinned piece exposes the King to attrition rather
  than instant death, so it is a bad idea rather than an illegal one.
- A back-rank "mate" is not a mate. The king simply keeps playing.

## 5. Holding the line

A player with **no legal move does not lose and does not draw — they hold.** The turn
passes and the opponent must come and take the garrison apart soldier by soldier.
Without this the game would deadlock the instant a king was cornered.

Both sides can hold in succession; the 50-move rule (which resets on any casualty, not
just captures) is what stops a stalemated board running forever.

## 6. Draws

- **Threefold repetition** — the position key now includes **every garrison count**.
  It has to: most attacks leave every piece on its square and only decrement a number,
  so a board-only key would read a long siege as one position repeating and declare a
  bogus draw.
- **Fifty-move rule** — resets on a pawn move or **any casualty**. A siege therefore
  never trips it; two armies staring at each other eventually does.
- Insufficient material no longer applies — any unit can grind down any other.

## 7. What to watch in playtesting

**Games are long.** Self-play at medium strength: 395–600 plies with ~200 casualties,
against roughly 80 plies for ordinary chess. One game in three hit the 50-move draw
without a king falling. Killing a fresh queen takes 15 winning duels; a king, 20.

The lever is the garrison table in §1 — it lives in one place (`SOLDIERS` in
`index.html`) and every probability and the computer opponent derive from it. Halving
the numbers roughly halves the game. The dice ladder is a second lever.

**A defender can walk away.** Because the attacker never advances on a won duel, a
wounded piece can simply retreat next turn. Attacking is therefore harassment that
forces a choice, not a commitment — a genuinely different game from the one-roll
version, and the thing most worth feeling out.

## 8. Implementation notes

- `SOLDIERS` and `ATK_DICE` are the two balance tables; everything else is derived.
- `state.souls` is a 64-slot array parallel to `state.board`, carried through
  `applyMove`, every search state, and every review snapshot.
- `applyMove(st, mv, attackerWins)` resolves **one duel**, not a capture. The board is
  unchanged unless that soldier was the unit's last.
- The computer opponent is still expectiminimax. A capture is a chance node whose two
  outcomes are "they lose a soldier" and "I lose a soldier", weighted by the matchup's
  real odds. `unitValue()` blends a fixed share of a piece's value with a share that
  scales with its garrison, so every soldier killed is measurable progress without a
  wounded queen becoming worthless.

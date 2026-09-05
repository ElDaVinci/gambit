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

The count is printed **on the piece itself** — dark digits on a white piece, light digits
on a black one — sitting over the base, the one solidly-filled area every silhouette
shares. It goes red on the last soldier. (An earlier version used a bubble badge in the
corner; two things to scan per square was too much.) **Damage is permanent** — there is no
healing, and a promoted pawn cannot carry more soldiers than its new rank allows.

## 2. An attack is an engagement of duels

Attacking an enemy piece opens an **engagement**, fought one duel at a time:

1. Each side sends one soldier. The attacker rolls its dice, the defender rolls one.
2. Each keeps its **highest single die**. Higher wins. Ties re-roll.
3. **One soldier dies — the loser's.**
4. **The attacker then chooses: press the attack, break off, or go all in.** Pressing
   fights another duel against *the same piece*; **all in** stops asking and runs the
   engagement to a conclusion — one side destroyed. There is no limit, and it is all
   one turn.

Both running garrisons are shown beside the two pieces at the top of the duel panel, so
the count you are spending sits next to the piece spending it.

**Pacing.** Every roll runs at the same readable pace — a 1.2 s throw, about 2.3 s per
duel. Nothing speeds up on its own. Whenever an engagement continues without asking (the
computer's assault, or an all-in) a **Fast forward** button is offered, and only pressing
it quickens the dice, to roughly 0.5 s per duel. It is a fast forward, not a skip: the
dice still visibly roll.

An earlier build quietly ran the computer's assaults at the quick pace by default. That
was not asked for and read as too fast — the lesson being that a button the player presses
is a different thing from a default they never chose.

**The King rolls four dice**, which in a single row is wider than the panel and hangs off
both edges. Four dice stack as a 2×2 block instead.

The engagement ends when the attacker breaks off, or when a garrison is emptied. A unit is
destroyed only when its **last** soldier falls; at that moment the attacker advances onto
the square, carrying its own remaining garrison with it. Break off instead and both pieces
stay exactly where they were, keeping every loss.

The attacker may only ever fight **the one piece it attacked** — an engagement cannot be
turned against a different target.

**This is what makes the game finish.** With one duel per turn a defender simply retreated
and games ran 400–600 plies; self-play now ends in **26–141 plies**, decisively (see §7).

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

## 7. Pace, measured

Sustained engagements fixed the pacing problem that one-duel-per-turn had:

| | one duel per turn | engagements (current) |
|---|---|---|
| Game length | 395–600 plies | **26–141 plies** |
| Decisive? | 1 of 3 drew on the 50-move rule | **4 of 4 ended with a king falling** |
| Duels per attack | 1 | ~7 average |

Ordinary chess is roughly 80 plies, so the game now sits in the right range. The reason is
simple: a defender used to just retreat between turns, and nothing could ever be finished.

**Still worth feeling out:** an engagement lets a strong attacker finish a weak piece in
one turn, so big pieces are far more dominant than under one-duel-per-turn. The counter is
that pressing a losing attack bleeds *your* garrison permanently, and breaking off early is
often right. The levers, in order of bluntness, are the garrison table (§1), the dice
ladder (§2), and capping duels per engagement.

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

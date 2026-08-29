# Battle Mechanics

The core system. This is a **draft to react to**, not a decision. See [[Open Questions]]
for the forks we still need to settle.

## The sequence of a capture

1. Player selects a piece and a target square occupied by an enemy piece.
2. The move must be **legal chess** (the piece could capture there in normal chess).
3. The game shows the **battle preview**: dice for each side + win % + what happens on
   each outcome.
4. Player confirms.
5. Both sides roll. Result is compared. Square is resolved.
6. **Turn passes regardless of outcome.**

## How many dice each side rolls

Your example: *pawn attacks knight → 3 dice vs 1 die.* Two ways to read that, and we
need to pick one (tracked in [[Open Questions]]):

### Option A — "you roll your opponent's strength"
Each side rolls dice equal to the **other** piece's combat rating.
- Pawn (1) attacks Knight (3): attacker rolls **3**, defender rolls **1**. Matches your
  example.
- Consequence: attacking *up* the value ladder is favoured. A pawn stabbing a queen
  (rolls 5) vs the queen (rolls 1) usually wins. Sacrificial chess becomes very strong —
  maybe too strong. Would need a cap or a penalty.

### Option B — "you roll your own strength, attacker gets an edge"
Each side rolls dice equal to **its own** combat rating; the attacker gets **+N bonus
dice** for choosing the fight (initiative).
- Pawn (1, +2 initiative = 3) attacks Knight (3): attacker rolls **3**, defender rolls
  **3**. Your "3 vs 1" would instead be "3 vs 3" — close fight, slight defender edge on
  ties.
- Consequence: strong pieces reliably win the fights they pick; weak-attacks-strong is
  a real long shot. This is closer to chess intuition.

### Option C — ratio-based
Dice are assigned from the **ratio** of ratings, normalised so the total is small
(e.g. max 5 dice on the table). Smoother scaling, more tuning knobs, harder to read at a
glance.

**My recommendation:** start with **Option B**. It preserves piece-value intuition, keeps
sacrifices spicy but not dominant, and the "initiative" bonus is a clean lever to tune.

## Comparing the rolls

Your phrasing was "whoever has the higher points wins" → **sum of all dice**.
- Attacker sum > defender sum → **capture succeeds** (normal chess result: attacker
  takes the square, defender removed).
- Attacker sum < defender sum → **capture fails** (see next section).
- **Tie** → defender wins (defender's advantage). Or: re-roll. Open question.

Alternative (true Risk style): compare **highest die to highest die**, then next-highest,
etc. More swingy, more "Risk-feel", less readable. Sum is simpler and easier to show a
clean % for. Recommend **sum**.

## What happens when the attacker loses

Pick one (Open Question):

| Outcome model      | On attacker loss                                              | Feel |
|--------------------|--------------------------------------------------------------|------|
| **Repelled**       | Attacker returns to its origin square, both pieces survive. Attacker lost the tempo only. | Forgiving. Encourages probing. |
| **Attacker falls** | Attacker is removed, defender stays on its square.           | Brutal, high stakes. A failed pawn-takes-queen just loses the pawn. |
| **Both fall**      | Attacker removed; defender also removed; square is empty.    | Mutual destruction. Weird for chess, interesting for tactics. |
| **Wounded**        | Attacker removed; defender survives but is "wounded" (rolls fewer dice next fight, or can be captured freely next turn). | Adds a state layer; more to build. |

**My recommendation:** **Attacker falls.** It makes the gamble matter, keeps the board
state clean, and mirrors your Risk comparison (the loser loses the unit). "Repelled" is
the gentle alternative if playtests feel too punishing.

## Worked examples (Option B, sum, attacker +2 initiative, ties→defender)

Combat ratings: P1 N3 B3 R4 Q5.

| Attack                    | Attacker dice | Defender dice | Rough attacker win % |
|---------------------------|---------------|---------------|----------------------|
| Pawn takes Pawn           | 3 (1+2)       | 1             | ~78%                 |
| Pawn takes Knight         | 3             | 3             | ~44%                 |
| Pawn takes Queen          | 3             | 5             | ~22%                 |
| Knight takes Pawn         | 5 (3+2)       | 1             | ~92%                 |
| Knight takes Knight       | 5             | 3             | ~72%                 |
| Queen takes Pawn          | 7 (5+2)       | 1             | ~96%                 |
| Queen takes Knight        | 7             | 3             | ~85%                 |
| Rook takes Queen          | 6 (4+2)       | 5             | ~55%                 |

(Percentages are back-of-envelope for sum-of-d6; we'll compute exact tables with a
simulator once code exists. The point is the *shape*: like-for-like ≈ coin flip, punching
up is a real risk, overwhelming force ≈ 85–96% but never certain.)

## Optional layer: support bonuses ("the many parameters")

If we want more of a real-battle feel, add **+1 die per friendly piece that also attacks
the target square** (attacker support) and **+1 die per friendly piece defending it**
(defender support), capped at +2 or +3 a side. This makes piece coordination matter and
turns the board into a genuine map of local force. It is optional and can be added after
the base game works.

Other parameters we *could* fold in later: passed-pawn / promotion-rank bonus, back-rank
"last stand" bonus for the defender, first-move jitters penalty, King's-guard aura, etc.
Keep the prototype minimal; note these for tuning.

## Things the battle system must not break

- **Check / checkmate logic.** If a capture of the King is a dice roll, "check" stops
  being forcing. Big fork in [[Open Questions]] — decide King rules first.
- **Legal-move generation.** Battles do not change which moves are legal, only what
  happens when a capture move is played.
- **Draw conditions.** A failed capture is still a move; does it reset the 50-move
  counter? (Proposed: yes, an attempted capture counts as a capture attempt = resets.)

# Open Questions

Decisions to make together before building. Ordered by how much they change the game.

## 1. The King — does it fight? (decide this first)

If capturing the King is also a dice roll, then "check" is no longer forcing and the
whole win condition changes.

- **1a. Classic King.** King is never battled. Check and checkmate work exactly as in
  chess. The dice twist applies only to pieces 1–7. *Safest; keeps chess recognisable.*
- **1b. King fights.** No check, no checkmate. You win by **capturing the King**, and
  that capture is a battle like any other. Putting a piece next to the enemy King is now
  a threat, not a mate. *Much bigger redesign; very different game.*
- **1c. Hybrid.** Checkmate still ends the game, BUT if you are in check you may try to
  "fight through" it — a King in check can be attacked, and that single capture is a
  battle. *Interesting, most complex to build and explain.*

**Recommendation:** 1a for the first version.

## 2. Dice allocation — which reading of your example?

See [[Battle Mechanics]] "How many dice each side rolls".
- **Option A** — each side rolls the *other* piece's rating (your literal "3 vs 1").
  Favours attacking up; sacrifices get strong.
- **Option B** — each side rolls its *own* rating; attacker gets +N initiative dice.
  Preserves piece-value intuition. **Recommended.**
- **Option C** — ratio-based, capped total.

Also: what is **N** (the attacker initiative bonus)? Proposed **+2**. Could be +1
(defender-friendly, grindier) or +3 (aggressive, faster games).

## 3. How rolls are compared

- **Sum of dice** (your "higher points wins"). Readable, clean %. **Recommended.**
- **Highest-die vs highest-die, Risk style.** Swingier, more Risk-flavoured, harder to
  show a single clean probability.

## 4. Tie result

- Defender wins ties (defender's advantage). **Recommended, simplest.**
- Re-roll until decisive.
- Attacker wins ties (aggressive).

## 5. What happens to the attacker on a loss

See table in [[Battle Mechanics]].
- **Attacker falls** (removed, defender stays). **Recommended.**
- Repelled (returns to origin, both live) — gentle alternative.
- Both fall / Wounded state — more complex.

## 6. Piece combat ratings

Starting proposal: **P1 N3 B3 R4 Q5** (King 4 if it fights). Compress the Queen so it is
strong, not invincible? Or keep classic-ish **P1 N3 B3 R5 Q9**? Needs a simulator to
tune, but pick a starting set.

## 7. Variance mitigation — do we want any of these in v1?

- **Preview odds** (always show win % before confirming). Strongly recommend yes.
- **Re-roll token:** each player gets 1–2 per game to force one re-roll.
- **"Morale" / pity:** after losing an X% or better fight, next fight gets +1 die.
- **No mitigation** — pure dice, let it ride.

## 8. Support bonuses (extra dice for coordinated pieces)

- **Off for v1**, add later. **Recommended** — get the base loop working first.
- On for v1: +1 die per extra friendly attacker / defender of the square, cap +2.

## 9. Failed capture and the 50-move / repetition counters

- A capture *attempt* resets the 50-move counter (treat like a capture). **Recommended.**
- Only a *successful* capture resets it.

## 10. Pawn promotion, en passant, castling

- Promotion: unchanged (reach last rank, choose a piece). If the promoting move is also
  a capture, battle first; promote only if it succeeds.
- En passant: it is a capture → it is a battle. Defender (the pawn) rolls its rating.
- Castling: no capture, no battle. Unchanged.

Confirm these are fine.

## 11. Format / platform for the build

- **Single self-contained HTML file**, vanilla JS. Runs by double-click, no install.
  Can also be published as a shareable Artifact link. **Recommended for the prototype.**
- Install Node.js (via `winget install OpenJS.NodeJS`) and build a Vite + TypeScript app.
  Better for a larger project, needs the install + a dev server.

---

## Answers (DECIDED 2026-08-29 — see [[Battle Mechanics]] for the authoritative ruleset)

| # | Question                         | Decision |
|---|----------------------------------|----------|
| 1 | King rules                       | **Classic.** King never rolls, never battled. Check/checkmate/stalemate as standard chess. King captures succeed automatically (no roll). |
| 2 | Dice allocation                  | **Flat: every piece rolls exactly 1d6.** Attacker 1d6 vs defender 1d6. Piece power stays in mobility only. |
| 3 | Sum vs highest-die               | N/A — one die each. |
| 4 | Ties                             | **Re-roll until decided** → clean 50/50. |
| 5 | Attacker-loss outcome            | **Attacking piece is removed from the board.** Defender stays on its square, unmoved. |
| 6 | Combat ratings                   | N/A — no per-piece ratings. |
| 7 | Variance mitigation              | **None in v1.** Pure dice. |
| 8 | Support bonuses in v1            | **None.** Flat 1d6 is the whole story. |
| 9 | 50-move counter on failed capture| **Does not reset.** Only pawn moves and successful captures reset it. |
| 10| Promotion / en passant / castle  | EP = battle. Castling = no battle. Capturing promotion = battle first, promote only on a win. |
| 10a| In-check play                   | Player keeps making moves until out of check; may risk further pieces on capture attempts; no escape possible = checkmate. |
| 11| Build format                     | **Single self-contained `index.html`** (vanilla JS). Built — see repo root. Also published as an Artifact for phone play. |

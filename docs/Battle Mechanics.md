# Battle Mechanics (v1 — locked)

Standard chess in every respect **except the resolution of captures.** Movement, check,
checkmate, castling, en passant, promotion, stalemate, threefold repetition, the pin
rule — all unchanged from normal chess. This file is the authoritative ruleset.

## 1. Move legality

Legality is computed exactly as in standard chess, **assuming any attempted capture would
succeed.** If a move is legal under that assumption, it may be played — a capture is then
played as an *attempt* (§2). Consequences:

- A pinned piece may still do only what standard chess allows: move along the pin line, or
  capture the pinning piece if it stands on that line.
- You may not play a move whose **successful** outcome would leave your own king in check.
- The **failed** outcome of a capture can still leave your king in check. That is handled
  in §4 — it does not make the attempt illegal.

## 2. Resolving a capture

Any capture — normal, en passant, or a capturing promotion — is a **battle**:

1. Each side rolls its dice and keeps its **highest** single die. The number of dice the
   **attacker** rolls depends on the piece; the **defender always rolls one** (see §2a).
2. Re-roll ties until one side is higher.
3. **Attacker higher →** capture succeeds. Standard chess result: the attacker moves onto
   the square, the defender is removed.
4. **Defender higher →** the **attacking piece is removed from the board.** The defender
   stays on its square, unmoved. Nothing else changes.

A capture attempt is the player's whole move for the turn, win or lose — **except while
the player's own king is in check (§4).**

## 2a. Attacking dice by piece (revised 2026-09-03)

**How many dice you roll to attack depends on the piece. The defender always rolls
exactly one, whatever it is.** Extra dice make a piece better at *taking*, never harder
to kill.

| Attacker | dice | attacker wins |
|---|---|---|
| **Queen** | 3 | **79.2 %** |
| **Rook / Bishop / Knight** | 2 | **69.4 %** |
| **Pawn** | 1 | **50.0 %** |
| *Any defender* | *1* | — |
| King | — | never battles (§3) |

Exact values: 1 die 50 %, best-of-2 `125/216 ÷ 5/6` = 69.44 %, best-of-3
`855/1296 ÷ 5/6` = 79.17 %. (The tie probability is 1/6 regardless of how many dice the
attacker rolls, which is why each figure is just `1.2 ×` the raw win chance.) Confirmed
against a 400,000-battle simulation: 50.00 / 69.36 / 79.22.

**Why "keep the higher" and not "sum".** Summing 3d6 against 1d6 wins about **98 %**,
which would make the Queen unstoppable and delete the dice from the game. Best-of-N is a
real edge that still loses often enough to matter — even the Queen loses one attack in five.

**History.** v1 gave every piece exactly one die (a flat 50 %), on the reasoning that
mobility already ranks the pieces in standard chess. That was then relaxed to give the
Queen two dice, and now to the full ladder above.

**Consequence to watch in playtesting.** This is the biggest balance change the game has
had, and it cuts against the original v1 rationale. Attacking is now favoured for every
piece except the pawn, so material stops being "sticky" and the game moves back toward
ordinary chess with a luck layer on top. Expected values move accordingly:

| trade | EV before (all 1d6) | EV now |
|---|---|---|
| Queen takes rook | −200 | **+208** |
| Queen takes pawn | −400 | **−108** |
| Rook takes knight | −90 | **+69** |
| Knight takes rook | +90 | **+249** |
| Knight takes pawn | −110 | **−28** |
| Pawn takes queen | +400 | +400 (unchanged) |

The thing to feel out: whether defending is now too weak — a defender has no way to
improve its odds, so a Queen attack is close to a free capture at 79 %.

**Implementation note.** The dice counts live in one table (`ATK_DICE` / `DEF_DICE` in
`index.html`) and the win probability is derived from them analytically, so the computer
opponent's expectiminimax stays correct automatically — verified: it declines
queen-takes-pawn and plays queen-takes-rook under the new odds. Changing the ladder is a
one-line edit to `ATK_DICE`.

## 3. The King

- The King never rolls dice and is never the target of a battle.
- Check, checkmate, stalemate, and "you may not leave your king in check" work exactly as
  in standard chess.
- A checking piece can be removed by another piece only through a successful capture
  battle (§2).
- **A King capturing an adjacent piece is not a battle — it succeeds automatically.** The
  King may only capture where standard chess allows (an undefended piece), so this never
  needs a roll.

## 4. Playing while in check

If your king is in check at any point during your turn — whether it was already in check
when the turn began, or a failed capture in §2 has just exposed it — **it remains your
turn and you keep making moves until your king is no longer in check.**

- Every move follows all normal rules, including that a capture is an attempt with a roll.
- You may attempt to capture the checking piece. If you lose, that piece is removed, you
  are still in check, and you continue the turn.
- You may spend as many moves — and risk as many pieces on failed capture attempts — as
  you choose in the effort to get out. That is the player's decision.
- The turn ends the instant your king is safe.
- If no sequence of legal moves can get your king out of check, it is **checkmate** and
  you lose.

### Worked example — pinned pawn captures the pinner

White: Ke1, Pd2.  Black: Qc3.  White to move.

The d2 pawn is pinned on the c3–d2–e1 diagonal. Standard chess allows `d2xc3` (a capture
along the pin line), so White may attempt it.

- **Pawn wins:** queen removed, pawn on c3, king safe. Turn ends.
- **Pawn loses:** pawn removed, queen still on c3, king on e1 now in check along the
  diagonal. White is in check and plays on — must now move the king, interpose, or attempt
  another capture of the queen — until out of check, or it is checkmate.

## 5. Special moves

- **En passant** — a capture, so a battle. If the attacker loses, the en-passant pawn is
  removed and the enemy pawn stays.
- **Castling** — not a capture, no battle. Succeeds whenever standard chess allows it.
- **Promotion** — if the promoting move is a capture, battle first. The pawn promotes only
  on a win; on a loss the pawn is removed and nothing promotes. A non-capturing promotion
  is automatic as normal.

## 6. Draw conditions

- **50-move counter** resets on pawn moves and **successful** captures only. A failed
  capture does not reset it — it is neither a pawn move nor a completed capture.
- Threefold repetition, stalemate, and insufficient material are unchanged from standard
  chess.

## 7. Consequences to watch in playtesting

- Every capture is 50/50 and a lost attack loses your piece for nothing, so material is
  "sticky" — expect fewer trades and a more positional, maneuvering game than chess.
- Forks, pins, and discovered attacks all become probabilistic. A knight fork on king +
  queen is only a 50% chance to actually win the queen.
- A check that can only be answered by capturing the checker is close to lethal (~50% per
  attempt, and each failed attempt costs a piece).
- The side that makes the opponent do the capturing has the edge.

## 8. Still open

- §4: may the extra in-check moves include actions **not** aimed at resolving the check
  (a speculative capture elsewhere on the board), or only check-resolving moves? Current
  draft assumes moves are made in the effort to escape; a rational player makes only
  escape-relevant moves regardless.
- Build format for the prototype (see [[Roadmap]]).

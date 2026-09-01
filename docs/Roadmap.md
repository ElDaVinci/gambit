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

## Phase 4 — computer opponent ✅ DONE

**Expectiminimax**, because plain minimax is wrong for this game: every capture is a
chance node with two equally likely children (attacker takes the square / attacker is
removed). The engine therefore plays the *expected value* of an attack —
`EV = ½·victim − ½·attacker` — which means it only initiates a capture when the target is
worth more than the piece it risks. Alpha-beta prunes the deterministic layers; chance
nodes get a full window, since pruning inside one is only sound after both branches are
known. The Gambit continuation rule is modelled too: if a failed capture leaves the mover
in check, the search keeps the same side on move (value not negated).

Evaluation: material (P100 N320 B330 R500 Q900) plus standard piece-square tables.

| Level  | Depth | Random move | Node cap | Typical / worst |
|--------|-------|-------------|----------|-----------------|
| Easy   | 1     | 45%         | 30k      | ~1 ms           |
| Medium | 2     | 12%         | 150k     | ~7 ms           |
| Hard   | 3     | —           | 500k     | 25 ms / 130 ms  |
| Master | 4     | —           | 900k     | 72 ms / ~2.5 s  |

Verified: refuses a −400 EV queen-takes-pawn 40/40 at medium and above; plays a +400 EV
pawn-takes-queen 20/20. Strength is correctly ordered — medium 6–0 easy, hard 4–0 medium.
8 headless self-play games all terminated in checkmate with no hangs; observed capture
failure rate 45%, matching the 50% model.

## Phase 5 — ship as an installable app ✅ DONE

Live at **https://eldavinci.github.io/gambit/** (repo: `ElDaVinci/gambit`, public,
Pages from `main` / root).

PWA: `manifest.webmanifest` + `sw.js` + `icons/`. Verified on the live host — service
worker registers and goes active, scope is correct, all 8 shell assets cached, HTTPS
enforced, every asset serves with the right MIME type.

**Why package before finishing the game:** a PWA wrapper is decoupled from the content.
Shipping a change is `git push` — the service worker updates itself, no re-packaging, no
store review. That is *not* true of a native app, where every iteration costs a rebuild
and an Apple review cycle. And getting it onto a phone home screen is what makes real
playtesting actually happen. Native remains an option later; it buys only store
discovery, push notifications, and in-app purchase, none of which matter yet.

**Release discipline:** bump `CACHE` in `sw.js` on every ship, or clients keep the stale
cache. Run `bash tools/build-artifact.sh` too, so the Artifact copy stays in sync.

## Game review ✅ DONE

After the game ends, **Review game** steps through it ply by ply. Each ply is stored as a
board snapshot (plus side to move and captured pieces) rather than replayed, so the dice
results you actually got are the ones you see — replaying would re-roll them and show a
different game.

Each step names the piece, the squares, and for a capture the **dice that decided it** —
`Queen Qh5xf7 — captured the pawn ([5 6]→6–4)` shows the queen's two attack dice, which
one was kept, and what the defender rolled. That is the part worth reviewing in Gambit:
not just what was played, but what the dice did to it.

Navigation: first/prev/next/last, arrow keys, Home/End, Escape to close, and clicking any
move in the log jumps straight to it. The board is read-only while reviewing.

## UI pass: standard chess-app conventions ✅ DONE

Adopted the layout conventions common to chess apps (Chess.com being the reference),
**without** copying their branding — Gambit keeps its slate-and-brass identity, which is
an asset, and cloning another product's trade dress is not something to do.

What changed:
- **Player cards** above and below the board — avatar, name, the pieces that side has
  captured, and its material lead (`+3`). The side to move is ringed in brass. Note the
  Gambit wrinkle: a *repelled* attacker dies, so it counts toward the defender's lead.
- **Coordinates inside the board edge** instead of outer gutters — standard, and it gives
  the board noticeably more room on a phone.
- **Board tools** under the board: Flip · Review · New game.
- **Manual board flip**, independent of the existing auto-rotate option.
- **Two-column move list** (number · White · Black) instead of one row per ply. A Gambit
  turn can hold several plies when playing on out of check, so a row keeps filling its
  column rather than assuming one ply per side.

Measured on a 375px viewport: board 343×343, cards flush to the board width, cards +
board + tools all above the fold, no horizontal scroll.

## Opening animation ✅ DONE

On load the board tiles in square by square on a diagonal sweep, the back rank drops onto
it, and the wordmark resolves. ~2.1s, skippable by tapping or the Skip button.

**Built so it can never leave a blank screen:** everything is visible by default and the
animation is layered on top under an `.animate` class. Relying on `animation-fill-mode:
forwards` to *reach* the visible state is fragile — if animations are disabled or cut
short the splash stays empty, which is exactly what happened in the first version. Under
`prefers-reduced-motion` the splash is shown un-animated and closes quickly.

## Start screen + training mode ✅ DONE

The app now opens on a **menu** instead of straight onto the board: a 2×2 grid of computer
strengths (Low / Medium / Hard / Master), a wide **Two players** tile, and a wide
**Training** tile. Choosing one configures the game and reveals the board; a **Menu**
button on the board returns.

**Training** is five short lessons, each a real position played on the real engine — the
dice genuinely roll, so a lesson about losing a capture can actually lose it:

1. *It is still chess* — movement is unchanged. Task: make any move.
2. *A capture is a fight* — 1d6 vs 1d6, 50/50. Task: take the pawn on d5.
3. *Losing costs you the piece* — the attacker dies and the defender stays.
4. *The Queen attacks with two dice* — 69%, and the overlay shows both cubes.
5. *Check, and playing on* — take the checking rook with the knight; if the knight loses
   you are still in check and keep moving.

Lesson 5 earns its place: in testing the knight lost the battle, died, White was still in
check, the turn continued, and the task only completed once the king was safe. The rule
teaches itself.

Two bugs found while building it, both worth remembering:
- Lesson 5's first position was K+B vs K — **insufficient material**, so the game ended in
  a draw the instant it loaded and took an early return that skipped the lesson check.
  The lesson-completion hook now lives in `pushHistory`, which runs on every path.
- `.game{display:grid}` outranked the UA `[hidden]{display:none}` rule, so the board
  rendered underneath the menu. Same trap as `.fields[hidden]` earlier — every element
  toggled with `hidden` now restates `display:none`.

## Start screen, second pass ✅ DONE

The first version was a list of labelled boxes — it read as a settings screen, not a chess
game, and said nothing about the dice. Rebuilt so the screen **states the premise by
demonstrating it**:

- A **live capture** at the top: a knight stands over a pawn with the target ringed in red,
  and two real 3D dice keep rolling to decide it — "Capture — the pawn falls" /
  "Repelled — the knight is lost". Same dice, same odds, same tie re-rolls as the game.
  The loop pauses while a game is running.
- **Chess pieces as the difficulty scale** instead of letters: pawn → knight → rook →
  queen for Low → Medium → Hard → Master. Rising piece value carries the meaning without a
  word of explanation. Two players shows both kings; Training shows a die face.
- Each icon sits on a board square, and the **piece colour follows the square** (white on
  dark, black on light) so it always reads — the first attempt put white pieces on light
  squares and they washed out.

Two CSS lessons, both about ordering and specificity:
- `.dieWrap` is defined later in the stylesheet than the hero rules, so `.heroDie` lost and
  the hero dice inherited the overlay's 64px. Needed `.heroRoll .dieWrap` to win.
- The hero took 359px of an 812px phone screen; a `max-width:430px` block brings it to
  231px so all four difficulty tiles are visible without scrolling.

## Phase 6 — next

- **Playtest.** Does the 50/50-everything feel good, or too swingy? Tune from real games.
  Self-play shows only 6–22 captures per game — material really is "sticky", as predicted.
  This is the biggest open risk in the project, and it is a design risk, not a technical one.
- Optional simulator: N random/greedy games, dump capture-attempt and game-length stats.
- Undo / takeback (tricky with committed dice — decide the rule first).
- Resolve the open §8 question (in-check speculative captures elsewhere on the board).
- Sound, capture/roll animations polish, board-theme options.
- FEN or PGN-style export/import for sharing positions.
- Stronger bot: quiescence search, transposition table, iterative deepening with a time
  budget instead of a fixed node cap.
- Node/Vite migration if warranted.
- Online play.

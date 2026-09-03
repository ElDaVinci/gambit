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

## Start screen, third pass ✅ DONE

- **Dice were showing ghost outlines.** `.face` had `backface-visibility: visible`, so the
  three faces pointing away from the camera rendered through the front one as stray
  outlines and pips. Set to `hidden`. Fixes the battle overlay dice too.
- **The 3×3 board is now a demo reel.** Nine squares kept. Six scenarios cycle
  (knight→pawn, rook→bishop, queen→rook, pawn→knight, queen→knight, rook→bishop), the
  dice tumble, and the result *plays out on the board*: on a capture the attacker steps
  onto the square and the defender fades away; when repelled the attacker is the one that
  falls. The queen's scenarios show two attacking dice.
  Outcomes deliberately alternate so both halves of the rule get shown — but the dice are
  rolled for real until they produce that outcome, so the faces on screen are always a
  valid roll for the result, never a fixed picture.
- **Training is always against the computer.** Every lesson has the learner as White, so
  someone must answer for Black. The Table panel's opponent switch is hidden during
  training — choosing an opponent is what the menu is for.
- **Back button, top left**, shown only inside a game.

## Tactical puzzles ✅ DONE

Training now has two tabs. **Rules** keeps the five dice lessons. **Puzzles** is real
tactics: pick Easy / Medium / Hard, the opponent plays the first move, and you find the win.

- Six puzzles: back-rank mate, queen-and-bishop mate, winning the queen, Scholar's finish,
  a forced block, and a smothered mate (queen sacrifice, then the knight).
- **Hint** highlights the square of the piece that must move and prints a one-line clue.
- The goal line states the target and the move count — "Mate in 2 · 2 moves" — and counts
  down as you go. Wrong moves are rejected and the position resets.

**Puzzle captures resolve without dice**, and the UI says so. A tactic that runs through a
capture would otherwise be unsolvable whenever the roll went against you, testing luck
instead of the idea. The rules lessons still roll for real.

Every puzzle is verified against the engine rather than by eye: the opening move and each
solution move must be legal, each scripted reply must be the opponent's *only* legal move,
and mate puzzles must end in real checkmate (not stalemate) with the declared move count.
Two of my first drafts failed that check and were replaced — one "win the queen" gained no
material because the queen had already stepped off the square, and one mate-in-2's second
move was illegal once the blocker arrived.

## Hero fixes ✅ DONE

- **Pips overflowed small dice.** Padding and pip size were fixed pixels tuned for the
  64px overlay die; on the 44px menu die three 11px pips did not fit in 26px of space and
  spilled outside the face. Now proportional (`padding:13%`, `width:66%`).
- **The attacker vanished on a capture.** The piece was sized at 78% of a square, so
  `translateY(-100%)` moved it only 0.78 of a square and it came to rest between two.
  Now full-size with padding, so one `-100%` is exactly one square — measured landing
  error is 0%.

## Opening animation — full board + thrown dice ✅ DONE (v17 → v18)

The splash used to drop in only the white back rank — eight pieces on an otherwise
empty board. It now assembles the **full 32-piece starting position**: `#splashRank`
became a full 8×8 grid overlay pixel-aligned to the tile board (empty middle squares are
bare `<i>` spacers), so both back ranks drop in first, then both pawn ranks in front of
them, each rank staggered across its files.

A new `#splashDice` layer throws **three dice** onto the board. They reuse the battle
overlay's `buildDie` / `rollDie` machinery.

- **v17:** dice fell straight down (`diceFall`), sized at a fixed 34px.
- **v18:** die size is now a fraction of the board — `--dieS: calc(var(--bd) * .086)`,
  measured at **0.69 of a square** at every width, down from ~1.17. The motion is a
  hand-thrown `diceThrow`: each die flies in low and fast from off the board's
  lower-right corner (`--fromX` / `--fromY`), overshoots, skips hard off the surface,
  bounces ~9px then ~3px, and settles at a slight angle (`--rz`). Each keyframe segment
  carries its own timing function so the bounces have real physics (decelerate up to
  each apex, accelerate down). The cube tumbles 6–10 turns concurrently on its `.dieBox`
  transition. The shadow splats, lifts, and re-splats in time with the bounces. Dice are
  thrown as a quick handful (90 ms apart), each with a slightly different trajectory.

Under `prefers-reduced-motion` the dice are placed statically on their faces and the
whole splash is shown un-animated, as before.

Verified by DOM measurement + Web-Animations replay of the exact keyframes (screenshots
and compiled CSS animation are untestable here — the browsers force reduced-motion and
the pane doesn't composite): 32 pieces render with the correct per-type counts (16 pawns,
4/4/4 minor+rook, 2 queens, 2 kings), 16 white / 16 black; the piece and dice overlays
are pixel-aligned to the board; each die is 0.69× a square with six faces and a correct
pip layout and lands on a valid 1–6 face; the `diceThrow` trajectory samples as a
fly-in → overshoot → skip → 9px bounce → 3px bounce → rest; the splash builds with no JS
errors and removes itself cleanly, leaving the menu visible.

## Sound no longer stops the player's music ✅ DONE (v19)

Starting a game killed whatever the player had playing (Spotify, Apple Music, a podcast).
Two things from the earlier "I can't hear any sound" fix were responsible, and both were
doing the same thing for the same reason — claiming the device's audio session:

1. `navigator.audioSession.type = "playback"` declares the page to be **primary media
   playback**, which is an instruction to iOS to interrupt everything else.
2. A silent, **looping** `<audio>` keepalive element ran for the whole session. A media
   element that is *playing* holds the audio session even when its samples are all zero —
   that was the older-iOS fallback for the same silent-switch problem.

Now the game declares **`type = "ambient"`** — the mixing category — and creates no media
element at all (pure Web Audio). The session is claimed at script load *and* immediately
before the `AudioContext` is constructed, because on iOS the category is fixed at context
creation time; setting it afterwards is too late.

**The tradeoff, stated plainly:** iOS honours the physical ring/silent switch for
`ambient` sessions. With the switch on silent the game is now quiet — which is exactly
how every other app that mixes behaves, and is the price of not interrupting. Reverting
is a one-word change (`"ambient"` → `"playback"`), at the cost of stopping music again.

Verified: no `new Audio(...)`, no media elements, and no `"playback"` session type remain
anywhere in the file; the audio graph still builds and runs (`AudioContext` reaches
`state: "running"` with the master gain connected, nothing thrown). The gesture-unlock
path is untouched. The `ambient` declaration itself is a Safari-only API and could not be
observed here — Chrome has no `navigator.audioSession`, and both test browsers report a
0×0 viewport so no trusted tap could be dispatched.

## A wrong puzzle move no longer resets by itself ✅ DONE (v20)

A move that missed printed a verdict and then a `setTimeout` wiped the position 2.2 s
later. You lost the board before you had finished looking at it, and the restart was the
app's decision rather than yours. All three auto-reset timers are gone. Now:

- The **position stays exactly as you left it.** The square the piece came from is tinted
  red (`.sq.missFrom`), the square it landed on is ringed red (`.sq.missTo`).
- The board **freezes** — no second move can be played into a dead line.
- The coach names the mistake *and why*, without ever naming the answer.
- **Retry becomes the primary button**; Skip drops to secondary. Nothing happens until
  the player presses one.

The freeze is a dedicated `puzzleFrozen()` predicate, deliberately **not** the `busy`
flag: `checkPuzzle` runs from inside `pushHistory`, which `finalize()` calls *before* its
own `busy=false`, so anything set there is overwritten a few lines later. That was a real
bug caught in testing — the first version set `busy=true` and the board stayed live.

`gradeMove` now appends a concrete reason built from the position the played move actually
produced, in priority order: (1) the moved piece can be captured where it now stands,
(2) the move left another piece hanging that was safe before, (3) it simply is not
forcing. It describes the *consequence*, never the solution.

Verified against the engine on all 6 puzzles across all 3 difficulties: every wrong move
halts in `state:"wrong"`, marks the correct two squares, and freezes all 64 squares
(0 pickable); the position is unchanged 6 s later; Retry restores a clean playable puzzle
(red cleared, 12 pickable, Hint re-enabled); the correct move still reaches `"solved"`
with no red squares. The "can be taken on f7" claim was cross-checked through move
generation rather than `isAttacked` — Black really does have `Rf8xf7`.

## Attacking dice ranked by piece ✅ DONE (v21)

Queen 3, Rook / Bishop / Knight 2, Pawn 1 — attacking only. **The defender always rolls
one die.** Because the mechanic is table-driven (`ATK_DICE`) and the probability is derived
analytically, the rule itself was a one-line change and the bot retuned itself.

| Attacker | dice | wins |
|---|---|---|
| Queen | 3 | 79.2 % |
| Rook / Bishop / Knight | 2 | 69.4 % |
| Pawn | 1 | 50.0 % |

Exact values cross-checked against a 400,000-battle simulation of the real mechanic
(keep-highest, re-roll ties): 50.00 / 69.36 / 79.22 simulated. The engine's own
`captureOdds` returns 50 / 69.44 / 79.17 and is independent of the defender's identity,
as required.

**This reverses the original v1 rationale** that mobility already ranks the pieces, so the
dice should not. Every piece except the pawn now favours the attacker, material stops
being "sticky", and the game moves back toward ordinary chess with a luck layer. EV shifts:
queen×rook −200 → **+208**, rook×knight −90 → **+69**, knight×pawn −110 → **−28**. The bot
was verified to decline queen-takes-pawn (−108) and play queen-takes-rook (+208) under the
new table. The open question for playtesting is whether **defending is now too weak** — a
defender cannot improve its one die, so a queen attack is close to a free capture.

### Two layout problems the extra dice caused

1. **Battle overlay.** Three 64px dice are a 216px row; with the defender and the gap that
   is 314px inside a 360px panel — no slack. A three-die row now scales itself to 46px
   (`.dieRow[data-n="3"]`), keyed on the die count rather than a breakpoint, since it is
   the count that causes the overflow. Verified at 375px: children span 252px of 315px
   available, nothing scrolls.
2. **Menu hero.** `.heroSide` flex children had no `flex-shrink:0`, so a row under pressure
   would silently crush a die to zero width rather than overflow visibly. Added, plus a
   count-keyed shrink (42px, 32px on phones). Verified for 1, 2 and 3 attacking dice: no
   die below 8px, all six faces built, the roll stays inside the hero card, no page scroll.

**Testing note worth remembering:** measuring a die by `.dieBox` width is wrong. The box is
3D-rotated, so a die landing on face 2 or 5 sits edge-on at ±90° and legitimately reports
0 width. That produced a false "collapsed die" reading. Measure `.dieWrap`, which is not
transformed.

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

---
phase: 02-architectural-foundations
plan: 03
subsystem: ui
tags: [flutter, bloc, repaintboundary, performance, game-page]

# Dependency graph
requires:
  - phase: 02-01
    provides: HapticService extracted, ProgressionBloc registered — DI foundations for game page refactor

provides:
  - GamePage with BlocListener for side effects and 5 targeted BlocBuilders with buildWhen guards
  - 4 RepaintBoundary zones isolating header, score, board, and powerup repaint layers
  - _extractSession/_extractLevel helpers usable across all zone methods

affects:
  - 02-04
  - 03-animations
  - game-page rendering pipeline

# Tech tracking
tech-stack:
  added: []
  patterns:
    - BlocListener + multiple BlocBuilder pattern with buildWhen guards
    - RepaintBoundary zone isolation per UI zone
    - context.read<Bloc>().state in gesture callbacks (one-shot read, not subscription)

key-files:
  created: []
  modified:
    - lib/features/game/presentation/pages/game_page.dart

key-decisions:
  - "Keep HapticService.instance singleton pattern — plan suggested sl<HapticService>() but codebase uses HapticService.instance; consistency over deviation"
  - "Top-level BlocBuilder uses runtimeType guard (only rebuilds on Initial/Playing/Won/Lost transitions) not on every state change"
  - "Swipe handler reads isPaused via context.read<GameBloc>().state inside onPanEnd callback — safe one-shot read, avoids subscription"

patterns-established:
  - "Zone method pattern: each UI zone is a private method returning BlocBuilder<GameBloc, GameState> with buildWhen + RepaintBoundary"
  - "buildWhen early return: if either prev or curr is not GamePlaying, return true (always rebuild on state type transitions)"

requirements-completed:
  - PERF-03
  - PERF-04

# Metrics
duration: 7min
completed: 2026-03-26
---

# Phase 2 Plan 03: Architectural Foundations Summary

**GamePage render isolation via BlocListener + 5 targeted BlocBuilders with buildWhen guards and 4 RepaintBoundary zones — score repaints only on score/moveCount changes, board only on board changes, powerups only on powerup count changes**

## Performance

- **Duration:** 7 min
- **Started:** 2026-03-26T09:01:00Z
- **Completed:** 2026-03-26T09:08:31Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments

- Replaced monolithic BlocConsumer with BlocListener (side effects) + targeted BlocBuilder zones
- Score display now rebuilds only when `session.board.score` or `session.board.moveCount` changes — not on every swipe
- Board zone rebuilds only when `session.board` changes — not on score or powerup updates
- Powerup bar rebuilds only when any powerup count (`undosRemaining`, `hammersRemaining`, `shufflesRemaining`, `mergeBoostsRemaining`) changes
- Pause overlay rebuilds only when `session.status` changes
- Header is fully static per game session — wrapped in RepaintBoundary with no BlocBuilder
- All listener side effects preserved: juice effects, analytics, dialogs, mechanic intros

## Task Commits

1. **Task 1: Split BlocConsumer into BlocListener + targeted BlocBuilders with RepaintBoundary** - `e3e1c58` (feat)

## Files Created/Modified

- `lib/features/game/presentation/pages/game_page.dart` - Refactored from single BlocConsumer to BlocListener + 5 BlocBuilders with buildWhen guards and 4 RepaintBoundary zones

## Decisions Made

- Kept `HapticService.instance` singleton pattern instead of plan's suggested `sl<HapticService>()` — the existing codebase consistently uses the singleton; switching would have introduced an inconsistency without benefit
- Top-level BlocBuilder uses `prev.runtimeType != curr.runtimeType` as buildWhen guard — the scaffold only rebuilds on state type transitions (Initial→Playing, Playing→Won/Lost), not on in-game state changes
- Swipe handler reads `isPaused` via `context.read<GameBloc>().state` inside `onPanEnd` callback — this is a safe one-shot read in a callback, avoids the need for a BlocBuilder subscription just for the swipe guard

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Preserved HapticService.instance instead of sl<HapticService>()**
- **Found during:** Task 1 (zone method implementation)
- **Issue:** Plan's code samples used `sl<HapticService>()` but HapticService uses a singleton `instance` pattern and is not registered in GetIt DI
- **Fix:** Used `HapticService.instance` throughout zone methods, consistent with all other usages in the file
- **Files modified:** lib/features/game/presentation/pages/game_page.dart
- **Verification:** `flutter analyze` passes, no DI lookup errors
- **Committed in:** e3e1c58 (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (Rule 1 — bug: wrong service access pattern)
**Impact on plan:** Fix was necessary for correctness. All plan goals achieved. No scope creep.

## Issues Encountered

None — plan was precise and the refactor was mechanical once the existing code structure was understood.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- GamePage render isolation complete — PERF-03 and PERF-04 addressed
- Phase 02 now has all 3 plans complete (02-01 HapticService extraction, 02-02 ProgressionBloc, 02-03 GamePage render isolation)
- Ready for Phase 03 (animations) — the split BlocBuilders and RepaintBoundary zones provide clean attachment points for animation widgets per zone

---
*Phase: 02-architectural-foundations*
*Completed: 2026-03-26*

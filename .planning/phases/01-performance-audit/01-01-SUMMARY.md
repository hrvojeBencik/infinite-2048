---
phase: 01-performance-audit
plan: 01
subsystem: ui
tags: [flutter, performance, dev-tools, PerformanceOverlay, SchedulerBinding, frame-timing]

# Dependency graph
requires: []
provides:
  - perfOverlayNotifier ValueNotifier<bool> in lib/app/dev_flags.dart for toggling PerformanceOverlay at app root
  - PerformanceOverlay.allEnabled() wired into MaterialApp.router builder, survives navigation
  - PERFORMANCE section in dev options page with overlay toggle and regression check button
  - Scripted 20-swipe regression check with SchedulerBinding frame timing capture and pass/fail dialog
affects: [02-animation-polish, dev-tools, performance-fixes]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Package-level ValueNotifier gated by kDebugMode for dev-only feature flags"
    - "MaterialApp builder pattern for app-root overlays that survive route transitions"
    - "SchedulerBinding.addTimingsCallback for frame timing capture during automated tests"

key-files:
  created:
    - lib/app/dev_flags.dart
  modified:
    - lib/app/app.dart
    - lib/features/dev/presentation/pages/dev_options_page.dart

key-decisions:
  - "Used package-level ValueNotifier<bool>? (null in release) instead of DI registration — simpler, no service locator overhead for a debug flag"
  - "1-second warmup delay before timing capture to avoid measuring shader compilation jank"
  - "5% over-16ms threshold for regression pass/fail — matches 60fps budget with headroom for animation"
  - "Used activeThumbColor instead of deprecated activeColor for SwitchListTile"

patterns-established:
  - "Pattern: dev-only flags live in lib/app/dev_flags.dart as nullable package-level variables"
  - "Pattern: app-root overlays inserted via MaterialApp builder with kReleaseMode guard"

requirements-completed: [PERF-06, PERF-07]

# Metrics
duration: 12min
completed: 2026-03-26
---

# Phase 01 Plan 01: Performance Dev Tools Summary

**PerformanceOverlay toggle and scripted-swipe regression check wired into dev options page, gated by kDebugMode/kReleaseMode with SchedulerBinding frame timing capture and pass/fail reporting**

## Performance

- **Duration:** 12 min
- **Started:** 2026-03-26T08:20:40Z
- **Completed:** 2026-03-26T08:32:00Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Created `lib/app/dev_flags.dart` with `perfOverlayNotifier` as a package-level `ValueNotifier<bool>?` (null in release builds via `kDebugMode` gate)
- Wired `PerformanceOverlay.allEnabled()` into `MaterialApp.router` builder so the overlay persists across all route transitions when toggled
- Added PERFORMANCE section to dev options page with a `SwitchListTile` toggle and a "Run Regression Check" button that launches sandbox, waits 1s for shader warmup, dispatches 20 scripted swipes via `SchedulerBinding`, captures frame timings, and shows a pass/fail dialog with over-budget %, worst frame, and avg frame stats

## Task Commits

Each task was committed atomically:

1. **Task 1: Create dev_flags.dart and wire PerformanceOverlay into app root** - `236dafb` (feat)
2. **Task 2: Add PERFORMANCE section to dev options page with overlay toggle and regression check** - `cb9a3ee` (feat)

## Files Created/Modified

- `lib/app/dev_flags.dart` — Package-level `perfOverlayNotifier` ValueNotifier gated by kDebugMode; null in release builds
- `lib/app/app.dart` — MaterialApp.router builder that shows PerformanceOverlay when perfOverlayNotifier is true, with kReleaseMode safety guard
- `lib/features/dev/presentation/pages/dev_options_page.dart` — PERFORMANCE section with SwitchListTile overlay toggle and regression check button with full frame timing capture pipeline

## Decisions Made

- Used package-level `ValueNotifier<bool>?` (null in release) instead of registering in GetIt DI — simpler and zero overhead for a debug-only flag
- 1-second warmup delay before timing capture to avoid measuring shader compilation jank (per research pitfall)
- 5% over-16ms threshold for pass/fail — matches 60fps budget with headroom for real-world conditions
- Replaced deprecated `activeColor` with `activeThumbColor` + `activeTrackColor` on SwitchListTile

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed `const_with_non_const` error on PerformanceOverlay.allEnabled()**
- **Found during:** Task 1 (analyze verification)
- **Issue:** Plan code used `const PerformanceOverlay.allEnabled()` but the constructor is not const
- **Fix:** Removed `const` keyword
- **Files modified:** lib/app/app.dart
- **Verification:** flutter analyze reports no issues
- **Committed in:** 236dafb (Task 1 commit)

**2. [Rule 1 - Bug] Fixed `unnecessary_underscores` lint warning in ValueListenableBuilder**
- **Found during:** Task 1 (analyze verification)
- **Issue:** `(_, show, __)` triggered unnecessary_underscores lint rule
- **Fix:** Renamed parameters to `context2, show, child2`
- **Files modified:** lib/app/app.dart
- **Verification:** flutter analyze reports no issues
- **Committed in:** 236dafb (Task 1 commit)

**3. [Rule 1 - Bug] Fixed deprecated `activeColor` on SwitchListTile**
- **Found during:** Task 2 (analyze verification)
- **Issue:** `activeColor` is deprecated after Flutter v3.31.0-2.0.pre
- **Fix:** Replaced with `activeThumbColor` and `activeTrackColor`
- **Files modified:** lib/features/dev/presentation/pages/dev_options_page.dart
- **Verification:** flutter analyze reports no issues
- **Committed in:** cb9a3ee (Task 2 commit)

---

**Total deviations:** 3 auto-fixed (all Rule 1 bugs discovered during analyze verification)
**Impact on plan:** All auto-fixes necessary for clean compilation and lint compliance. No scope creep.

## Issues Encountered

None — all issues discovered and resolved during automated analyze verification steps.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Dev performance tools are ready for use during Phase 2 animation/jank fixes
- Developers should run regression check in `--profile` mode for accurate results (warning is shown in debug mode)
- The overlay toggle persists across navigation — toggle once from dev page, then navigate to any game screen to observe frame budget bars

---
*Phase: 01-performance-audit*
*Completed: 2026-03-26*

---
phase: 04-ux-flow-and-usability
plan: 02
subsystem: game/share
tags: [share, social, ux, dialogs]
dependency_graph:
  requires: ["04-01"]
  provides: ["score-sharing-via-share-sheet"]
  affects: ["level_complete_dialog", "game_over_dialog", "game_page"]
tech_stack:
  added: ["share_plus ^12.0.1"]
  patterns: ["RepaintBoundary image capture", "StatefulWidget sharing state", "off-screen widget render"]
key_files:
  created:
    - lib/features/game/presentation/widgets/share_score_card.dart
  modified:
    - pubspec.yaml
    - pubspec.lock
    - lib/features/game/presentation/widgets/level_complete_dialog.dart
    - lib/features/game/presentation/widgets/game_over_dialog.dart
    - lib/features/game/presentation/pages/game_page.dart
decisions:
  - "GameOverDialog converted from StatelessWidget to StatefulWidget to hold _isSharing state — consistent with LevelCompleteDialog which was already stateful"
  - "levelNumber added to GameOverDialog as optional param (default 0) — backward-compatible, game_page passes actual level number"
  - "Off-screen ShareScoreCard uses Positioned(left: -1000) inside Stack — renders silently outside viewport, painted by Flutter so RepaintBoundary.toImage() works"
  - "share_plus ^12.0.1 resolved (plan referenced ^10.0.0 which is outdated — latest compatible resolved by pub)"
metrics:
  duration: "4 minutes"
  completed_date: "2026-03-26T21:19:59Z"
  tasks_completed: 2
  files_changed: 5
---

# Phase 4 Plan 2: Score Sharing Summary

**One-liner:** Native score sharing via share_plus with branded ShareScoreCard captured as PNG through RepaintBoundary off-screen rendering.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Add share_plus and create ShareScoreCard widget | 9d4d346 | pubspec.yaml, pubspec.lock, share_score_card.dart |
| 2 | Add Share Score button to LevelCompleteDialog and GameOverDialog | 09fcff0 | level_complete_dialog.dart, game_over_dialog.dart, game_page.dart |

## What Was Built

- **ShareScoreCard widget** — self-contained branded card (320dp wide) showing score, highest tile, level number, app name ("2048: Merge Quest"), and tagline ("Play 2048: Merge Quest"). Zero BLoC dependencies; all data via constructor. Uses AppColors + GoogleFonts.
- **share_plus integration** — `SharePlus.instance.share(ShareParams(files: [XFile(path)]))` opens native share sheet with the captured PNG.
- **LevelCompleteDialog** — added `highestTile` required param, `_isSharing` state, `_shareCardKey` GlobalKey, `_shareScore()` async method, off-screen RepaintBoundary, and Share Score button (with spinner/idle states) in the secondary actions row.
- **GameOverDialog** — converted to StatefulWidget, added `levelNumber` optional param (default 0), same sharing infrastructure as LevelCompleteDialog. Share Score button placed between Try Again and Back to Levels.
- **game_page.dart** — updated both dialog call sites: `LevelCompleteDialog` now passes `highestTile: state.session.board.highestTile`, `GameOverDialog` now passes `levelNumber: state.level.levelNumber`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `withAlpha()` on const AppColors in ShareScoreCard**
- **Found during:** Task 1
- **Issue:** Plan used `AppColors.primary.withAlpha(50)` on const colors inside a `const` `BoxDecoration`. `withAlpha()` cannot be called on const values in a const context.
- **Fix:** Removed `const` qualifier from the decoration and used direct color references — `AppColors.primaryLight` for level badge background, `AppColors.primary` for the tile row background. Avoids runtime const errors.
- **Files modified:** share_score_card.dart

**2. [Rule 3 - Blocking] share_plus version resolved to ^12.0.1**
- **Found during:** Task 1
- **Issue:** Plan specified `share_plus: ^10.0.0` but `flutter pub add share_plus` resolved to ^12.0.1 (latest compatible).
- **Fix:** Accepted pub resolution — ^12.0.1 is fully API-compatible for `SharePlus.instance.share(ShareParams(...))`.
- **Files modified:** pubspec.yaml, pubspec.lock

None of the deviations changed behavior — plan executed as designed.

## Known Stubs

None. ShareScoreCard renders real data from constructor params. All call sites pass actual game state values.

## Verification

- `flutter analyze --no-fatal-infos` — passes with no issues
- `ShareScoreCard` class exists in share_score_card.dart
- `'Share Score'` present in both level_complete_dialog.dart and game_over_dialog.dart
- `share_plus` in pubspec.yaml
- `SharePlus.instance.share` in both dialog files
- `RepaintBoundary` wraps ShareScoreCard in both dialogs

## Self-Check: PASSED

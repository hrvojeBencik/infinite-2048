---
phase: 02-architectural-foundations
plan: "01"
subsystem: core-services-di
tags: [haptic-service, progression-bloc, dependency-injection, bloc, refactor]
dependency_graph:
  requires: []
  provides:
    - HapticService DI-accessible singleton at lib/core/services/haptic_service.dart
    - ProgressionBloc global reactive state at lib/features/progression/presentation/bloc/
  affects:
    - lib/app/di.dart
    - lib/app/app.dart
    - lib/features/game/presentation/pages/game_page.dart
    - lib/features/endless/presentation/pages/endless_game_page.dart
    - lib/features/settings/presentation/pages/settings_page.dart
tech_stack:
  added: []
  patterns:
    - HapticService extracted from SoundService, registered as lazy singleton via GetIt
    - ProgressionBloc as lazy singleton global BLoC (vs route-scoped factory pattern)
    - sealed class hierarchy for ProgressionEvent and ProgressionState
key_files:
  created:
    - lib/core/services/haptic_service.dart
    - lib/features/progression/presentation/bloc/progression_bloc.dart
    - lib/features/progression/presentation/bloc/progression_event.dart
    - lib/features/progression/presentation/bloc/progression_state.dart
  modified:
    - lib/core/services/sound_service.dart
    - lib/app/di.dart
    - lib/app/app.dart
    - lib/features/game/presentation/pages/game_page.dart
    - lib/features/endless/presentation/pages/endless_game_page.dart
    - lib/features/settings/presentation/pages/settings_page.dart
decisions:
  - HapticService extracted as standalone file with public constructor — no static singleton, DI-managed lifetime
  - ProgressionBloc registered as lazy singleton (not factory) to share state globally across MultiBlocProvider
  - LoadProgression dispatched on BlocProvider create so player profile and active theme are resolved at app startup
metrics:
  duration_minutes: 3
  completed_date: "2026-03-26"
  tasks_completed: 2
  files_modified: 9
---

# Phase 2 Plan 1: HapticService Extraction and ProgressionBloc Foundation Summary

**One-liner:** HapticService extracted from SoundService into standalone DI-managed file; ProgressionBloc created as global reactive state source holding PlayerProfile and active TileTheme from Hive.

## What Was Built

Foundation for PERF-02 (TileThemes reactive refactor). Two coordinated changes:

1. **HapticService extraction** — The `HapticService` class was embedded inside `sound_service.dart` as a static singleton (`HapticService.instance`). It has been moved to its own file `lib/core/services/haptic_service.dart` with a public default constructor, registered in DI as `sl.registerLazySingleton<HapticService>()`. All 9 call sites in game_page, endless_game_page, settings_page, and sound_service now use `sl<HapticService>()` instead of `HapticService.instance`.

2. **ProgressionBloc** — New BLoC with two events (`LoadProgression`, `UpdateTileTheme`) and two states (`ProgressionInitial`, `ProgressionLoaded` carrying `PlayerProfile` and `TileTheme`). Registered as a lazy singleton in DI and provided globally in `app.dart` MultiBlocProvider with `LoadProgression` dispatched on create, so the active tile theme is resolved from Hive on app startup and available reactively throughout the widget tree.

## Tasks Completed

| Task | Description | Commit |
|------|-------------|--------|
| 1 | Extract HapticService, create ProgressionBloc/Event/State files | 8e98229 |
| 2 | Wire DI, global BlocProvider, update all HapticService call sites | af45a9f |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed unused sound_service.dart imports**
- **Found during:** Task 2 verification (flutter analyze reported 2 warnings)
- **Issue:** `endless_game_page.dart` and `settings_page.dart` imported `sound_service.dart` but never used `SoundService` directly — the import became unused after haptic migration
- **Fix:** Removed the unused `sound_service.dart` import from both files
- **Files modified:** `lib/features/endless/presentation/pages/endless_game_page.dart`, `lib/features/settings/presentation/pages/settings_page.dart`
- **Commit:** af45a9f (included in Task 2 commit)

## Known Stubs

None — all functionality is fully wired. ProgressionBloc reads from Hive on startup and emits real player profile data.

## Self-Check: PASSED

- FOUND: lib/core/services/haptic_service.dart
- FOUND: lib/features/progression/presentation/bloc/progression_bloc.dart
- FOUND: lib/features/progression/presentation/bloc/progression_event.dart
- FOUND: lib/features/progression/presentation/bloc/progression_state.dart
- FOUND: commit 8e98229 (Task 1)
- FOUND: commit af45a9f (Task 2)

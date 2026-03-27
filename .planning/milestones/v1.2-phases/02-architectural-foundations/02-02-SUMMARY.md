---
phase: 02-architectural-foundations
plan: 02
subsystem: tile-rendering
tags: [performance, refactor, bloc, tile-themes]
requirements: [PERF-02]

dependency_graph:
  requires: [02-01]
  provides: [reactive-tile-theme, perf-02-fix]
  affects: [tile_widget, tile_themes, theme_selection]

tech_stack:
  added: []
  patterns: [context.select for reactive BLoC reads, theme parameter threading]

key_files:
  created: []
  modified:
    - lib/core/theme/tile_themes.dart
    - lib/features/game/presentation/widgets/tile_widget.dart
    - lib/features/progression/presentation/pages/theme_selection_page.dart

decisions:
  - "Used domain_theme alias for tile_theme.dart import to avoid naming collision with core TileThemes utility class"
  - "Moved Stack into AnimatedBuilder builder to give theme access — avoids stale theme in child parameter"

metrics:
  duration_minutes: 7
  completed_date: "2026-03-26T09:10:21Z"
  tasks_completed: 2
  files_modified: 3
---

# Phase 02 Plan 02: TileThemes Reactive Refactor Summary

**One-liner:** Eliminated 4,800 regex/Hive ops per second by removing TileThemes._activeTheme(), wiring TileWidget to ProgressionBloc via context.select, and dispatching theme changes through the bloc from ThemeSelectionPage.

## Tasks Completed

| # | Task | Commit | Key Changes |
|---|------|--------|-------------|
| 1 | Remove Hive/regex from TileThemes, update TileWidget | 1065a10 | tile_themes.dart, tile_widget.dart |
| 2 | Update ThemeSelectionPage to dispatch through ProgressionBloc | 37c8c75 | theme_selection_page.dart |

## What Was Built

**TileThemes (lib/core/theme/tile_themes.dart):** Now a pure utility class with zero Hive reads or regex operations. Removed: `_activeTheme()`, `_extractThemeId()`, `tileColor()`, `tileTextColor()`. Kept: `tileFontSize()`, `specialTileOverlay()`, `zoneGradient()`. The `hive_flutter` import and `as theme_model` import alias are fully removed.

**TileWidget (lib/features/game/presentation/widgets/tile_widget.dart):** `build()` now resolves the active `TileTheme` once via `context.select<ProgressionBloc, domain_theme.TileTheme>()` with a `TileThemes.classic` fallback when the bloc is in its initial state. The theme is threaded as a parameter through `_buildTile()`, `_getTileMainColor()`, `_tileDecoration()`, and `_valueContent()`. The double `_tileDecoration()` call is eliminated — the result is cached in a local variable within the `AnimatedBuilder` builder. The Stack was moved inside the `AnimatedBuilder` builder so it can receive the theme; this is correct because the Stack rebuilds with the glow animation anyway.

**ThemeSelectionPage (lib/features/progression/presentation/pages/theme_selection_page.dart):** `_selectTheme()` now dispatches `UpdateTileTheme(theme.id)` to `ProgressionBloc` via `context.read`. The local setState re-read of the profile is retained for the page's own active-indicator UI state. The bloc handles the Hive write and emits a new `ProgressionLoaded` state that `TileWidget.build()` picks up reactively.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Stack moved inside AnimatedBuilder builder for theme access**
- **Found during:** Task 1
- **Issue:** Plan described passing theme as a parameter to `_buildTile()` and using the `child:` optimization of `AnimatedBuilder` for the Stack. However, the Stack contains `_valueContent()` which needs the theme — if placed in `child:` it would be built once at creation with a stale/no-theme reference.
- **Fix:** Moved the Stack into the `builder:` closure of `AnimatedBuilder` so it receives the current theme on every animation rebuild. This is correct since the Stack was rebuilding on every glow tick anyway.
- **Files modified:** lib/features/game/presentation/widgets/tile_widget.dart
- **Commit:** 1065a10

**2. [Rule 2 - Missing critical] Import alias to resolve TileThemes naming collision**
- **Found during:** Task 1
- **Issue:** Both `lib/core/theme/tile_themes.dart` and `lib/features/progression/domain/entities/tile_theme.dart` export a class named `TileThemes`. Without an alias the Dart analyzer would have a conflict.
- **Fix:** Imported the domain entity file as `domain_theme` alias — all domain `TileTheme`/`TileThemes` references use the `domain_theme.` prefix. Core `TileThemes.tileFontSize()` remains unaliased.
- **Files modified:** lib/features/game/presentation/widgets/tile_widget.dart
- **Commit:** 1065a10

## Known Stubs

None — all tile color lookups are fully wired to live ProgressionBloc state.

## Self-Check: PASSED

Files exist:
- lib/core/theme/tile_themes.dart — FOUND
- lib/features/game/presentation/widgets/tile_widget.dart — FOUND
- lib/features/progression/presentation/pages/theme_selection_page.dart — FOUND

Commits exist:
- 1065a10 — FOUND
- 37c8c75 — FOUND

Verification:
- No `_activeTheme` in lib/ — PASSED
- No `_extractThemeId` in lib/ — PASSED
- No `TileThemes.tileColor` calls in lib/ — PASSED
- No `TileThemes.tileTextColor` calls in lib/ — PASSED
- `context.select<ProgressionBloc` in tile_widget.dart — PASSED
- `UpdateTileTheme` in theme_selection_page.dart — PASSED
- `flutter analyze` — No issues found

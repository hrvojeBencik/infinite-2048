# Phase 2: Architectural Foundations - Context

**Gathered:** 2026-03-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Fix the structural sources of jank identified in Phase 1: refactor TileThemes from per-frame Hive/regex reads to a reactive ProgressionBloc, add RepaintBoundary isolation to the game page widget tree, add buildWhen guards to GamePage's BLoC consumers, and extract HapticService into its own file with DI registration. This phase produces architectural changes — no visual/animation changes (those are Phase 3).

</domain>

<decisions>
## Implementation Decisions

### TileThemes Refactor (PERF-02)
- **D-01:** Create a new `ProgressionBloc` that holds the full player profile including active tile theme, XP, streaks — not just tile theme.
- **D-02:** Full profile migration from Hive into ProgressionBloc. The bloc reads from Hive on init and caches the state reactively. Downstream widgets subscribe to ProgressionBloc state instead of calling `TileThemes._activeTheme()` directly.
- **D-03:** `TileThemes` static class is refactored to receive a `TileTheme` parameter instead of reading Hive/regex per call. Eliminates the 4,800 regex ops/sec jank source.
- **D-04:** ProgressionBloc follows existing BLoC conventions: `lib/features/progression/presentation/bloc/` with separate events, state, and bloc files.

### RepaintBoundary Placement (PERF-03)
- **D-05:** Three RepaintBoundary zones on the game page: (1) header/controls area, (2) score display, (3) game board. Swiping on the board must not repaint score or header.
- **D-06:** Minimal boundaries for maximum impact — no per-tile boundaries or over-engineering.

### BLoC Rebuild Guards (PERF-04)
- **D-07:** Replace the single `BlocConsumer<GameBloc, GameState>` on GamePage with multiple targeted `BlocBuilder` widgets, each with `buildWhen` targeting only the fields it cares about.
- **D-08:** Score display rebuilds only when score changes. Board rebuilds only when board/tiles change. Controls rebuild only when powerup counts change.
- **D-09:** Scope is GamePage only — other pages (home, levels, achievements, endless) keep their current BLoC consumers unchanged.

### HapticService Extraction
- **D-10:** Move `HapticService` from `lib/core/services/sound_service.dart` to its own file `lib/core/services/haptic_service.dart`.
- **D-11:** Register as singleton in `di.dart` and access via `sl<HapticService>()` instead of `HapticService.instance`. Update all call sites (game_page.dart, settings_page.dart, endless_game_page.dart, sound_service.dart).

### Claude's Discretion
- ProgressionBloc state shape and event design
- Exact `buildWhen` conditions for each BlocBuilder
- Whether to keep TileThemes as a utility class or fold into ProgressionBloc
- Order of implementation (which refactor first)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Core files to refactor
- `lib/core/theme/tile_themes.dart` — Primary refactor target. `_activeTheme()` reads Hive + regex per call. Must be changed to accept a TileTheme parameter or removed entirely.
- `lib/features/game/presentation/pages/game_page.dart` — Single BlocConsumer wrapping entire page (line 238). Must be split into targeted BlocBuilders with RepaintBoundary zones.
- `lib/features/game/presentation/bloc/game_state.dart` — GameState with 6 Equatable fields. Understand structure for buildWhen design.
- `lib/features/game/presentation/bloc/game_bloc.dart` — GameBloc event handling. Understand what triggers state changes.
- `lib/features/game/presentation/widgets/tile_widget.dart` — Calls TileThemes.tileColor() and tileTextColor(). Must be updated to receive theme from ProgressionBloc.
- `lib/core/services/sound_service.dart` — Contains HapticService singleton to extract.
- `lib/app/di.dart` — DI registrations. Add ProgressionBloc and HapticService here.

### Progression feature (create new)
- `lib/features/progression/domain/entities/tile_theme.dart` — Existing TileTheme entity. ProgressionBloc will use this.
- `lib/features/progression/` — Existing progression feature directory. ProgressionBloc goes in `presentation/bloc/`.

### Phase 1 outputs
- `.planning/phases/01-performance-audit/PERF-BASELINE.md` — Documents jank sources, severity, and Phase 2 fix priorities
- `.planning/phases/01-performance-audit/01-CONTEXT.md` — Phase 1 decisions (D-01 through D-07)

### Project planning
- `.planning/REQUIREMENTS.md` — PERF-02, PERF-03, PERF-04 are this phase's requirements

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **Progression feature directory** (`lib/features/progression/`): Already has `domain/entities/` with TileTheme. New ProgressionBloc fits naturally in `presentation/bloc/`.
- **BLoC pattern**: All existing BLoCs follow the same structure (events file, state file, bloc file). ProgressionBloc should match.
- **GetIt DI** (`di.dart`): All services registered here. Pattern is clear — add ProgressionBloc and HapticService.

### Established Patterns
- **Equatable states**: All BLoC states use Equatable with `props`. ProgressionState should follow.
- **Hive for persistence**: Player profile stored as JSON string in Hive settings box. ProgressionBloc reads on init.
- **Singleton access**: `HapticService.instance` is the exception — all other services use `sl<T>()`.
- **GameBloc provides**: Created per-route in router.dart, not globally.

### Integration Points
- **app.dart**: ProgressionBloc should be provided globally (like AuthBloc, SubscriptionBloc, AchievementsBloc).
- **router.dart**: GamePage route creates GameBloc. ProgressionBloc accessed from parent context.
- **tile_widget.dart**: Reads TileThemes.tileColor(value). After refactor: reads theme from ProgressionBloc context or receives as parameter.

### Known Issues (from Phase 1)
- **TileThemes._activeTheme()**: 4,800 regex ops/sec on UI thread (5 calls per tile per frame at 60fps on 4x4 board)
- **Zero RepaintBoundary**: Entire game page repaints on every state change
- **Single BlocConsumer**: No buildWhen guards on GamePage — every field change triggers full rebuild

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard Flutter/BLoC architectural patterns for the refactor.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 02-architectural-foundations*
*Context gathered: 2026-03-26*

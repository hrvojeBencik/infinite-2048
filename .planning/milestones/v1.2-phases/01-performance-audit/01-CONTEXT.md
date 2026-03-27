# Phase 1: Performance Audit - Context

**Gathered:** 2026-03-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Establish a documented performance baseline on a physical mid-range device, identify real jank sources through profiling (not hypothetical), wire dev-only frame timing tools into the existing dev page, and audit SoundService for memory leak risk. This phase produces measurements and a report — no code fixes (those are Phase 2).

</domain>

<decisions>
## Implementation Decisions

### Target Devices
- **D-01:** Android is the primary profiling platform — if it hits 60fps there, iOS is assumed fine. iOS gets a spot-check only.
- **D-02:** Claude defines "mid-range" baseline criteria (Snapdragon 7-series / A14-era, 4-6GB RAM). User matches a device from their collection.
- **D-03:** Profiling runs in `--profile` mode on a physical device (not emulator).

### Dev Tool Design
- **D-04:** Frame timing overlay is a toggle switch in the existing dev options page (`lib/features/dev/presentation/pages/dev_options_page.dart`), using Flutter's `PerformanceOverlay` widget. Gated behind `kDebugMode` like the rest of the dev page.
- **D-05:** Performance regression check is an automated frame budget test: a dev page button that runs a scripted gameplay sequence (spawn tiles, swipe, merge) and reports pass/fail with frame time stats (any frames exceeding 16ms).

### Findings Documentation
- **D-06:** All findings go into a structured Markdown report (`PERF-BASELINE.md`) in `.planning/phases/01-performance-audit/`. Sections: baseline frame times, identified jank sources ranked by severity, TileThemes audit, SoundService audit, recommended fixes for Phase 2. No inline code comments.

### SoundService Scope
- **D-07:** SoundService has no actual AudioPlayer implementation — it's a haptic-only placeholder. PERF-05 is marked resolved/N-A with a note in the report. If real audio is added in a future milestone, re-audit then.

### Claude's Discretion
- Specific mid-range device criteria (exact chipset/RAM thresholds)
- Scripted gameplay sequence design for the regression test
- Jank severity ranking methodology
- Report structure and section ordering within PERF-BASELINE.md

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Performance-related source files
- `lib/core/theme/tile_themes.dart` — Confirmed jank source: `_activeTheme()` reads Hive + runs regex per call. Called from `tileColor()`/`tileTextColor()` which are invoked per-tile per-frame. Phase 1 documents this; Phase 2 fixes it.
- `lib/core/services/sound_service.dart` — Haptic-only placeholder, no AudioPlayer usage. PERF-05 resolved here.
- `lib/features/game/presentation/widgets/tile_widget.dart` — TileWidget with 3 AnimationControllers (merge, spawn, glow). Key widget to profile for rebuild frequency.
- `lib/features/dev/presentation/pages/dev_options_page.dart` — Integration point for new dev tools (frame overlay toggle, regression test button).
- `lib/app/di.dart` — DI setup, registers SoundService. Check for audioplayer-related registrations.

### Project planning
- `.planning/REQUIREMENTS.md` — PERF-01, PERF-05, PERF-06, PERF-07 are this phase's requirements
- `.planning/research/ARCHITECTURE.md` — Integration points and build order context
- `.planning/research/PITFALLS.md` — Debug-mode testing blindness pitfall (must profile in --profile mode)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **Dev options page** (`dev_options_page.dart`): Already gated behind `kDebugMode`, has toggle switches pattern — new toggles (frame overlay) fit naturally here.
- **GameBloc / GamePage**: Main gameplay surface to profile. Entry point for understanding rebuild patterns.

### Established Patterns
- **Hive for settings**: `SoundService` and `HapticService` both read from Hive box per-call. This pattern is widespread.
- **BLoC state management**: `flutter_bloc` used throughout — `buildWhen` guards are the expected optimization pattern.
- **GetIt DI**: All services registered in `di.dart` via `sl<T>()`.

### Integration Points
- **Dev page route**: `/dev` route in `router.dart`, debug-only. New tools go here.
- **Game page**: Primary profiling target — swipe handling, tile rendering, score updates.
- **TileWidget**: Most performance-critical widget — renders every tile with animations.

### Known Jank Sources (pre-profiling)
- **TileThemes._activeTheme()**: Hive read + regex per call — called multiple times per tile per frame. Architectural fix deferred to Phase 2 (PERF-02).
- **No RepaintBoundary usage**: Zero instances in codebase. Game board, score, and controls all repaint together on any state change.

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard Flutter profiling approaches (DevTools timeline, PerformanceOverlay, --profile mode).

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 01-performance-audit*
*Context gathered: 2026-03-26*

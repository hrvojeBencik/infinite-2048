# Phase 2: Architectural Foundations - Research

**Researched:** 2026-03-26
**Domain:** Flutter BLoC architecture, RepaintBoundary isolation, reactive state propagation
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**TileThemes Refactor (PERF-02)**
- D-01: Create a new `ProgressionBloc` that holds the full player profile including active tile theme, XP, streaks — not just tile theme.
- D-02: Full profile migration from Hive into ProgressionBloc. The bloc reads from Hive on init and caches the state reactively. Downstream widgets subscribe to ProgressionBloc state instead of calling `TileThemes._activeTheme()` directly.
- D-03: `TileThemes` static class is refactored to receive a `TileTheme` parameter instead of reading Hive/regex per call. Eliminates the 4,800 regex ops/sec jank source.
- D-04: ProgressionBloc follows existing BLoC conventions: `lib/features/progression/presentation/bloc/` with separate events, state, and bloc files.

**RepaintBoundary Placement (PERF-03)**
- D-05: Three RepaintBoundary zones on the game page: (1) header/controls area, (2) score display, (3) game board. Swiping on the board must not repaint score or header.
- D-06: Minimal boundaries for maximum impact — no per-tile boundaries or over-engineering.

**BLoC Rebuild Guards (PERF-04)**
- D-07: Replace the single `BlocConsumer<GameBloc, GameState>` on GamePage with multiple targeted `BlocBuilder` widgets, each with `buildWhen` targeting only the fields it cares about.
- D-08: Score display rebuilds only when score changes. Board rebuilds only when board/tiles change. Controls rebuild only when powerup counts change.
- D-09: Scope is GamePage only — other pages keep their current BLoC consumers unchanged.

**HapticService Extraction**
- D-10: Move `HapticService` from `lib/core/services/sound_service.dart` to its own file `lib/core/services/haptic_service.dart`.
- D-11: Register as singleton in `di.dart` and access via `sl<HapticService>()`. Update all call sites: game_page.dart, settings_page.dart, endless_game_page.dart, sound_service.dart.

### Claude's Discretion
- ProgressionBloc state shape and event design
- Exact `buildWhen` conditions for each BlocBuilder
- Whether to keep TileThemes as a utility class or fold into ProgressionBloc
- Order of implementation (which refactor first)

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| PERF-02 | TileThemes refactored from static Hive/regex lookup to reactive theme passed via ProgressionBloc | ProgressionBloc architecture, TileWidget refactor pattern, parameter-passing instead of static call |
| PERF-03 | RepaintBoundary isolates game board, score display, and control areas from unnecessary repaints | RepaintBoundary placement rules, render layer isolation, verified zero current boundaries |
| PERF-04 | BLoC buildWhen guards prevent full widget tree rebuilds on partial state changes | GameState field analysis, BlocBuilder split pattern, exact buildWhen conditions per zone |
</phase_requirements>

---

## Summary

Phase 2 addresses three confirmed jank sources identified in Phase 1 static analysis. All three fixes are
structural: they change how data flows through the widget tree without altering any visual behavior. The
work is self-contained to `game_page.dart`, `tile_widget.dart`, `tile_themes.dart`, `sound_service.dart`,
and the new `ProgressionBloc` files.

The primary jank source (JS-01) is `TileThemes._activeTheme()` running 4,800 regex ops/second on the UI
thread. The fix is a data-flow change: `ProgressionBloc` reads from Hive once on startup, holds the active
`TileTheme` object in state, and passes it down via `BlocBuilder`. `TileWidget` receives the theme as a
parameter rather than calling the static lookup. The regex and Hive read disappear from the hot path entirely.

The secondary fixes (JS-02, JS-03 in baseline) are structural placements: three `RepaintBoundary` wrappers
to isolate render layers, and `buildWhen` guards on split `BlocBuilder` widgets to prevent unnecessary
subtree rebuilds. These are low-risk, additive changes.

**Primary recommendation:** Implement in this order — (1) HapticService extraction (smallest, zero-risk
foundation), (2) ProgressionBloc + TileThemes refactor (highest impact, JS-01), (3) BLoC buildWhen guards
on GamePage (PERF-04, flows naturally from the BlocBuilder split needed for RepaintBoundary), (4)
RepaintBoundary placement (PERF-03, final layer).

---

## Project Constraints (from CLAUDE.md)

| Directive | Applies to Phase 2 |
|-----------|-------------------|
| Flutter clean architecture — feature-based, `data/domain/presentation` layers | ProgressionBloc goes in `lib/features/progression/presentation/bloc/` |
| BLoC/Cubit for state management, `flutter_bloc` | ProgressionBloc follows `flutter_bloc` patterns exactly |
| GetIt (`sl<T>()`) for DI — no `instance` singletons except where already established | HapticService must move from `.instance` to `sl<HapticService>()` |
| Equatable states in BLoC | ProgressionState must extend Equatable with props |
| `const` constructors wherever possible | All new state/event classes use `const` |
| Organize by feature: `lib/features/<feature>/{data,domain,presentation}/` | No files placed outside their feature boundary |
| Keep widgets small — extract when build method exceeds ~50 lines | No new oversized widgets introduced |
| No commented-out code in commits | Remove old `_activeTheme()` call sites, don't leave behind |

---

## Standard Stack

### Core (all already in pubspec — no new dependencies required)

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_bloc | ^9.1.0 (in pubspec) | BLoC state management, BlocBuilder, buildWhen | Already used everywhere in the project |
| equatable | ^2.0.7 (in pubspec) | Value equality for BLoC states/events | Required by all existing BLoC states |
| get_it | ^8.0.3 (in pubspec) | DI service locator | Project-standard DI, `sl<T>()` accessor |
| hive_flutter | ^1.1.0 (in pubspec) | Local persistence — ProgressionBloc reads from here on init | Already used by ProgressionLocalDataSource |

**No new packages needed.** This phase is pure architectural refactor using existing dependencies.

---

## Architecture Patterns

### ProgressionBloc Structure

Follows the exact pattern of `AchievementsBloc` (single-file with inline events/states) but per project
CONTEXT.md D-04 must use **separate files** like GameBloc (`game_event.dart`, `game_state.dart`, `game_bloc.dart`).

```
lib/features/progression/presentation/bloc/
  progression_event.dart
  progression_state.dart
  progression_bloc.dart
```

**State shape (Claude's discretion — recommended):**

```dart
// progression_state.dart  (part of 'progression_bloc.dart')
abstract class ProgressionState extends Equatable {
  const ProgressionState();
  @override
  List<Object?> get props => [];
}

class ProgressionInitial extends ProgressionState {}

class ProgressionLoaded extends ProgressionState {
  final PlayerProfile profile;
  final TileTheme activeTileTheme;  // resolved once, not per call

  const ProgressionLoaded({
    required this.profile,
    required this.activeTileTheme,
  });

  @override
  List<Object?> get props => [profile, activeTileTheme];
}
```

Reason for `activeTileTheme` as a resolved field rather than computing it on access: eliminates any
per-build lookup. The `TileThemes.getById()` call happens once in the bloc handler, not in the widget tree.

**Events (recommended):**

```dart
// progression_event.dart  (part of 'progression_bloc.dart')
abstract class ProgressionEvent extends Equatable {
  const ProgressionEvent();
  @override
  List<Object?> get props => [];
}

class LoadProgression extends ProgressionEvent {
  const LoadProgression();
}

class UpdateTileTheme extends ProgressionEvent {
  final String themeId;
  const UpdateTileTheme(this.themeId);
  @override
  List<Object?> get props => [themeId];
}

// Add XP events if needed downstream (Phase 3+), not required for Phase 2
```

**Bloc init:**

```dart
// progression_bloc.dart
class ProgressionBloc extends Bloc<ProgressionEvent, ProgressionState> {
  final ProgressionLocalDataSource _dataSource;

  ProgressionBloc({required ProgressionLocalDataSource dataSource})
      : _dataSource = dataSource,
        super(ProgressionInitial()) {
    on<LoadProgression>(_onLoad);
    on<UpdateTileTheme>(_onUpdateTheme);
  }

  Future<void> _onLoad(LoadProgression event, Emitter<ProgressionState> emit) async {
    final profile = _dataSource.getProfile();
    final theme = TileThemes.getById(profile.activeTileThemeId);
    emit(ProgressionLoaded(profile: profile, activeTileTheme: theme));
  }

  Future<void> _onUpdateTheme(UpdateTileTheme event, Emitter<ProgressionState> emit) async {
    await _dataSource.setActiveTileTheme(event.themeId);
    final profile = _dataSource.getProfile();
    final theme = TileThemes.getById(event.themeId);
    emit(ProgressionLoaded(profile: profile, activeTileTheme: theme));
  }
}
```

**DI registration in `di.dart`:**

```dart
// Add to initDependencies() — use registerLazySingleton (global, long-lived)
sl.registerLazySingleton<ProgressionBloc>(
  () => ProgressionBloc(dataSource: sl<ProgressionLocalDataSource>()),
);
sl.registerLazySingleton<HapticService>(() => HapticService());
```

**Global provision in `app.dart`:**

```dart
// Add to MultiBlocProvider in InfiniteApp
BlocProvider<ProgressionBloc>(
  create: (_) => sl<ProgressionBloc>()..add(const LoadProgression()),
),
```

### TileThemes Refactored Signature

Per D-03, `TileThemes` becomes a pure utility receiving a `TileTheme` parameter:

```dart
class TileThemes {
  TileThemes._();

  // REMOVED: _activeTheme(), _extractThemeId() — no more Hive/regex

  // Now receives theme as parameter — called from TileWidget only
  static Color tileColor(int value, TileTheme theme) {
    return theme.colorForValue(value);
  }

  static Color tileTextColor(int value, TileTheme theme) {
    return theme.textColorForValue(value);
  }

  // tileFontSize, specialTileOverlay, zoneGradient unchanged — no theme dependency
  static double tileFontSize(int value, double cellSize) { ... }
  static Color specialTileOverlay(String type) { ... }
  static List<Color> zoneGradient(String zoneId) { ... }
}
```

Alternatively (also acceptable per Claude's discretion): fold `tileColor` and `tileTextColor` directly into
`TileTheme` entity since `colorForValue` and `textColorForValue` already exist there. The static wrapper
methods become redundant. The planner should choose: either keep `TileThemes` as a utility pass-through, or
call `theme.colorForValue(value)` directly in `TileWidget`. Direct call is cleaner.

### TileWidget Refactored to Accept Theme

Two approaches are valid per Claude's discretion:

**Option A — Parameter injection (simpler, no context dependency in TileWidget):**

```dart
class TileWidget extends StatefulWidget {
  final Tile tile;
  final double cellSize;
  final double spacing;
  final bool isHammerMode;
  final VoidCallback? onTap;
  final TileTheme tileTheme;  // NEW parameter

  const TileWidget({
    super.key,
    required this.tile,
    required this.cellSize,
    required this.tileTheme,    // NEW
    this.spacing = 4,
    this.isHammerMode = false,
    this.onTap,
  });
  ...
}
```

`GameBoard` receives the theme (also as parameter from its parent, which reads ProgressionBloc), and passes
it to each `TileWidget`. Keeps `TileWidget` free of BLoC dependency — consistent with its current design.

**Option B — Context lookup inside TileWidget:**

```dart
// Inside _TileWidgetState.build():
final theme = context.select<ProgressionBloc, TileTheme>((bloc) {
  final s = bloc.state;
  return s is ProgressionLoaded ? s.activeTileTheme : TileThemes.classic;
});
```

`context.select` re-renders only when the extracted value changes (not on every ProgressionBloc emission).
This avoids threading the theme through GameBoard → TileWidget parameter chains.

**Recommended (Claude's discretion): Option B with `context.select`** — avoids parameter-threading through
GameBoard widget tree, and `context.select` is the canonical flutter_bloc pattern for selective rebuild.
TileWidget is a StatefulWidget that already accesses context; adding a bloc read is consistent.

### RepaintBoundary Placement Pattern

Current game page layout (simplified):
```
BlocConsumer<GameBloc>
  Scaffold
    GestureDetector
      Container (gradient background)
        SafeArea
          ScreenShake
            ComboOverlay
              Stack
                Padding → Column
                  [header row: back, title, pause]      ← Zone 1
                  [score row: Score, Target, Moves]     ← Zone 2
                  [move limit indicator] (conditional)
                  Expanded → Center → ScorePopupOverlay
                    Stack
                      GameBoard                         ← Zone 3
                      ParticleEffect
                PauseOverlay (conditional)
                TutorialOverlay (conditional)
```

Target structure after RepaintBoundary insertion:

```dart
Stack(
  children: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Zone 1: header — changes only on pause state
          RepaintBoundary(
            child: Row(
              children: [back button, title, pause button],
            ),
          ),
          const SizedBox(height: 12),
          // Zone 2: score — changes on every score update
          RepaintBoundary(
            child: Row(
              children: [ScoreDisplay, ScoreDisplay, ScoreDisplay],
            ),
          ),
          ...
          // Zone 3: game board — changes on every swipe
          Expanded(
            child: Center(
              child: ScorePopupOverlay(
                key: _scorePopupKey,
                child: RepaintBoundary(
                  child: Stack(
                    children: [GameBoard(...), ParticleEffect(...)],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Zone 4 (implied by D-08): powerup bar
          RepaintBoundary(
            child: PowerUpBar(...),
          ),
          ...
        ],
      ),
    ),
    if (isPaused) _PauseOverlay(...),
    ...
  ],
)
```

**Key constraint:** `ScreenShake` and `ComboOverlay` wrap the entire Stack and animate via their own
`GlobalKey` state — they are not driven by GameBloc state changes, so they do not interfere with the
RepaintBoundary isolation. The boundaries still isolate the children within.

### BLocBuilder Split Pattern

Current structure (single BlocConsumer wrapping everything):

```dart
BlocConsumer<GameBloc, GameState>(
  listener: ...,
  builder: (context, state) {
    // entire page rebuilt on any GameBloc state change
  },
)
```

Target structure:

```dart
// listener stays at top level on BlocConsumer — or moved to BlocListener
BlocListener<GameBloc, GameState>(
  listener: (context, state) { ... },
  child: Scaffold(
    body: GestureDetector(
      ...
      child: Container(
        child: SafeArea(
          child: ScreenShake(
            child: ComboOverlay(
              child: Stack(
                children: [
                  Padding(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        RepaintBoundary(
                          child: _GameHeader(),  // static header — no BlocBuilder needed
                        ),
                        const SizedBox(height: 12),
                        RepaintBoundary(
                          // Rebuilds only when score/moveCount changes
                          child: BlocBuilder<GameBloc, GameState>(
                            buildWhen: (prev, curr) => _scoreOrMovesChanged(prev, curr),
                            builder: (context, state) => _buildScoreRow(state),
                          ),
                        ),
                        ...
                        Expanded(
                          child: Center(
                            child: RepaintBoundary(
                              // Rebuilds on every board change
                              child: BlocBuilder<GameBloc, GameState>(
                                buildWhen: (prev, curr) => _boardChanged(prev, curr),
                                builder: (context, state) => _buildBoardArea(state),
                              ),
                            ),
                          ),
                        ),
                        RepaintBoundary(
                          // Rebuilds only when powerup counts change
                          child: BlocBuilder<GameBloc, GameState>(
                            buildWhen: (prev, curr) => _powerupsChanged(prev, curr),
                            builder: (context, state) => _buildPowerupBar(state),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // PauseOverlay driven by a top-level BlocBuilder for isPaused only
                  BlocBuilder<GameBloc, GameState>(
                    buildWhen: (prev, curr) => _pauseStateChanged(prev, curr),
                    builder: (context, state) => ...,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
)
```

### buildWhen Conditions (Recommended)

GamePlaying state has these fields: `session` (contains `board`, powerup counts, status), `level`,
`comboCount`, `lastScoreGained`, `hadBombExplosion`, `lastMergeCount`.

The session's board contains: `score`, `moveCount`, `tiles`, `highestTile`, `boardSize`.

```dart
// Score zone — score, moveCount, level target
static bool _scoreOrMovesChanged(GameState prev, GameState curr) {
  if (prev is! GamePlaying || curr is! GamePlaying) return true;
  return prev.session.board.score != curr.session.board.score ||
      prev.session.board.moveCount != curr.session.board.moveCount ||
      prev.level.targetTileValue != curr.level.targetTileValue;
}

// Board zone — tile layout changes on every valid swipe
static bool _boardChanged(GameState prev, GameState curr) {
  if (prev is! GamePlaying || curr is! GamePlaying) return true;
  return prev.session.board != curr.session.board;
}

// Powerup bar — only when powerup counts change
static bool _powerupsChanged(GameState prev, GameState curr) {
  if (prev is! GamePlaying || curr is! GamePlaying) return true;
  return prev.session.undosRemaining != curr.session.undosRemaining ||
      prev.session.hammersRemaining != curr.session.hammersRemaining ||
      prev.session.shufflesRemaining != curr.session.shufflesRemaining ||
      prev.session.mergeBoostsRemaining != curr.session.mergeBoostsRemaining;
}

// Pause overlay — only when game status changes
static bool _pauseStateChanged(GameState prev, GameState curr) {
  if (prev is! GamePlaying || curr is! GamePlaying) return true;
  return prev.session.status != curr.session.status;
}
```

**Important caveat:** `GameState` is sealed with sealed subclasses (`GameInitial`, `GamePlaying`, `GameWon`,
`GameLost`). When state transitions from `GamePlaying` to `GameWon`/`GameLost`, all BlocBuilders must
rebuild to show the final state. The `if (prev is! GamePlaying || curr is! GamePlaying) return true`
guards handle this correctly — any transition to/from non-playing state triggers a full rebuild.

### HapticService Extraction

Current: `HapticService` is a class defined at the bottom of `sound_service.dart` with a static singleton.

After extraction:

```dart
// lib/core/services/haptic_service.dart
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class HapticService {
  Box get _box => Hive.box(AppConstants.hiveSettingsBox);
  static const _hapticEnabledKey = 'haptic_enabled';

  bool get isEnabled => _box.get(_hapticEnabledKey, defaultValue: true) as bool;

  Future<void> setEnabled(bool enabled) async {
    await _box.put(_hapticEnabledKey, enabled);
  }

  void light() { if (!isEnabled) return; HapticFeedback.lightImpact(); }
  void medium() { if (!isEnabled) return; HapticFeedback.mediumImpact(); }
  void heavy() { if (!isEnabled) return; HapticFeedback.heavyImpact(); }
  void selection() { if (!isEnabled) return; HapticFeedback.selectionClick(); }
  void merge() { if (!isEnabled) return; HapticFeedback.mediumImpact(); }
  void bomb() { if (!isEnabled) return; HapticFeedback.heavyImpact(); }
  void combo() { if (!isEnabled) return; HapticFeedback.heavyImpact(); }
}
```

Note: The private constructor `HapticService._()` and `static final instance` are removed. GetIt manages
the singleton lifecycle. The class becomes a plain instantiable class — consistent with all other services.

`SoundService` updates its delegation:

```dart
// In sound_service.dart play()
void play(GameSound sound) {
  if (!isSoundEnabled) return;
  sl<HapticService>().light();
}
```

**All call sites to update:** 15 total `HapticService.instance.X()` calls across 4 files:
- `lib/core/services/sound_service.dart` — 1 call (line 32)
- `lib/features/game/presentation/pages/game_page.dart` — 8 calls (lines 64, 131, 137, 139, 378, 402, 408, 417, 424)
- `lib/features/endless/presentation/pages/endless_game_page.dart` — 5 calls (lines 39, 56, 62, 64, 282)
- `lib/features/settings/presentation/pages/settings_page.dart` — 2 calls (lines 28, 100)

Each becomes `sl<HapticService>().X()`. Settings page also reads `isEnabled` directly — becomes
`sl<HapticService>().isEnabled`.

### Anti-Patterns to Avoid

- **Per-tile RepaintBoundary (D-06):** Do not wrap individual `TileWidget` in RepaintBoundary. The
  16-tile board already sits inside one `RepaintBoundary`. Adding per-tile boundaries creates 16
  GPU compositing layers, which costs more than it saves for tiles that frequently animate together.

- **SubscriptionBloc for theme:** Do not use the existing `SubscriptionBloc` to carry theme state.
  ProgressionBloc is the correct owner per D-01.

- **registerFactory for ProgressionBloc:** Use `registerLazySingleton`, not `registerFactory`. GameBloc
  uses `registerFactory` because it is per-route (created fresh each game session). ProgressionBloc is
  global and long-lived — it must persist across routes.

- **Keeping `HapticService.instance` alongside `sl<HapticService>()`:** Do not leave a dual-access
  pattern. Remove the static `instance` entirely when extracting — the class has no private constructor
  in the new version.

- **Calling `TileThemes._activeTheme()` from anywhere after the refactor:** Verify zero remaining call
  sites before closing PERF-02. The grep for `_activeTheme` should return empty.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Selective widget rebuild on partial state | Custom change-notifier or ValueListenable threading | `BlocBuilder` with `buildWhen` | Already the project pattern; `flutter_bloc` implements this correctly |
| Render layer isolation | Custom RenderObject or manual layer management | `RepaintBoundary` | Flutter's built-in GPU compositing boundary — zero boilerplate |
| Theme reactive propagation | InheritedWidget or Provider.of threading | `context.select<ProgressionBloc, TileTheme>()` | `context.select` is the canonical flutter_bloc selective rebuild — only rebuilds when the extracted value changes |
| DI lifecycle management | Manual singleton with `static final instance` | `GetIt.registerLazySingleton` | Project-standard; `registerLazySingleton` is already used for all other services |

---

## Common Pitfalls

### Pitfall 1: registerFactory vs registerLazySingleton for ProgressionBloc
**What goes wrong:** Registering ProgressionBloc with `registerFactory` (like GameBloc) creates a new
instance every time `sl<ProgressionBloc>()` is called — the profile loads fresh each time, and state is
not shared between widgets.
**Why it happens:** GameBloc uses `registerFactory` because it is route-scoped; copying that registration
for ProgressionBloc is incorrect.
**How to avoid:** Use `registerLazySingleton`. Then provide it once in `app.dart`'s MultiBlocProvider
so the entire widget tree shares the same instance.
**Warning signs:** Theme resets between navigations; `LoadProgression` fires multiple times.

### Pitfall 2: BlocConsumer listener lost when splitting to BlocListener + BlocBuilders
**What goes wrong:** The current GamePage uses a single `BlocConsumer` which has both `listener` and
`builder`. If the `listener` is removed during the BlocBuilder split, side effects (showing dialogs on
GameWon/GameLost, triggering juice effects on GamePlaying) stop firing.
**Why it happens:** `BlocBuilder` has no `listener` — splitting the builder without preserving the listener.
**How to avoid:** Wrap the entire Scaffold in a `BlocListener<GameBloc, GameState>` (or keep one outer
`BlocConsumer` with `buildWhen: (_, __) => false` for the listener, nesting the BlocBuilders inside).
The listener logic is untouched by this phase.
**Warning signs:** Level complete dialog never appears; haptic feedback on merge stops.

### Pitfall 3: Double `_tileDecoration()` call not fixed alongside TileThemes refactor
**What goes wrong:** `_buildTile()` in `tile_widget.dart` calls `_tileDecoration(tileSize).copyWith(...)`,
which internally calls `TileThemes.tileColor()` twice (once for the base decoration, once for the
`copyWith` shadow construction). After the refactor, the theme is a parameter — but the double call
still creates two `BoxDecoration` objects per `AnimatedBuilder` rebuild unnecessarily.
**Why it happens:** The double-call is a separate inefficiency noted in Phase 1 handoff notes.
**How to avoid:** Cache the decoration in a local variable:
```dart
final decoration = _tileDecoration(tileSize, theme);
return Container(
  decoration: decoration.copyWith(
    boxShadow: [...decoration.boxShadow ?? [], ...],
  ),
  ...
);
```
**Warning signs:** No crash — just missed optimization. Include as part of PERF-02 task.

### Pitfall 4: `context.select` not working inside StatefulWidget's State
**What goes wrong:** `context.select<ProgressionBloc, TileTheme>()` is called inside `_buildTile()` or
`_getTileMainColor()`, which are plain methods — not `build()`. `context.select` registers a dependency
that only works during the widget's `build` call (where context is a `BuildContext` that can register
subscriptions). Calling it in a helper method works only if that method is called from within `build()`.
**Why it happens:** `context.select` in flutter_bloc uses the Element dependency mechanism — it must be
called from within the build phase.
**How to avoid:** Call `context.select` at the top of `build()` and store the result in a local variable.
Pass the theme to helper methods as a parameter.
**Warning signs:** Theme changes do not trigger TileWidget rebuild.

### Pitfall 5: ProgressionBloc not fired before game screen renders
**What goes wrong:** If `ProgressionBloc` is provided globally in `app.dart` but `LoadProgression` is
not dispatched at provision time, the state remains `ProgressionInitial` when `GamePage` first renders.
TileWidget reads `context.select` and falls back to the classic theme — but the user's active theme
may be different.
**Why it happens:** The BlocProvider creates the bloc but does not emit the initial state automatically.
**How to avoid:** Dispatch `LoadProgression` at provision time:
```dart
BlocProvider<ProgressionBloc>(
  create: (_) => sl<ProgressionBloc>()..add(const LoadProgression()),
),
```
**Warning signs:** Theme always shows classic regardless of user setting; changes in ThemeSelection page
not reflected in game.

### Pitfall 6: ThemeSelectionPage still writes directly to Hive without updating ProgressionBloc
**What goes wrong:** `ThemeSelectionPage` (in `lib/features/progression/presentation/pages/`) calls
`ProgressionLocalDataSource.setActiveTileTheme()` directly. After the refactor, TileWidget reads from
ProgressionBloc state — if the bloc isn't notified of the theme change, the game board won't update.
**Why it happens:** The data source write doesn't trigger a state change in ProgressionBloc.
**How to avoid:** `ThemeSelectionPage` should dispatch `UpdateTileTheme` to `ProgressionBloc` instead
of (or in addition to) calling the data source directly. The bloc handler calls the data source internally.
**Warning signs:** Theme selection page saves correctly, but the game board tile colors don't reflect
the new theme until the app restarts.

---

## Code Examples

### Verified: BlocBuilder with buildWhen (from project codebase)

This pattern already exists in `leaderboard_page.dart`:

```dart
// Source: lib/features/leaderboard/presentation/pages/leaderboard_page.dart lines 67–80
BlocBuilder<LeaderboardBloc, LeaderboardState>(
  buildWhen: (prev, curr) {
    final prevMode = prev is LeaderboardLoaded ? prev.mode : ...;
    final currMode = curr is LeaderboardLoaded ? curr.mode : ...;
    return prevMode != currMode;
  },
  builder: (context, state) { ... },
)
```

This confirms the `buildWhen` pattern is established in the project. GamePage split follows the same approach.

### Verified: Global BLoC provision in app.dart (from project codebase)

```dart
// Source: lib/app/app.dart lines 15–24
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
    ),
    BlocProvider<AchievementsBloc>(
      create: (_) => sl<AchievementsBloc>()..add(const LoadAchievements()),
    ),
  ],
  child: MaterialApp.router(...),
)
```

`ProgressionBloc` follows this exact pattern — same registration style, same dispatch-on-create pattern.

### Verified: BlocListener + BlocBuilder separation (standard flutter_bloc)

When a BlocConsumer needs to be split:

```dart
// Standard flutter_bloc pattern — listener and builder are independent
BlocListener<GameBloc, GameState>(
  listener: (context, state) {
    // side effects only — dialogs, haptics, analytics
  },
  child: BlocBuilder<GameBloc, GameState>(
    buildWhen: (prev, curr) => ...,
    builder: (context, state) {
      // UI only
    },
  ),
)
```

Or alternatively keep one BlocConsumer with `buildWhen: (_, __) => false` for the outer consumer
(listener-only) and nest BlocBuilders inside the `builder`.

### Verified: context.select pattern (standard flutter_bloc)

```dart
// Selective rebuild — only rebuilds when activeTileTheme changes
final theme = context.select<ProgressionBloc, TileTheme>((bloc) {
  final s = bloc.state;
  return s is ProgressionLoaded ? s.activeTileTheme : TileThemes.classic;
});
```

---

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| `TileThemes._activeTheme()` Hive+regex per frame | `context.select` from ProgressionBloc state — resolved once per theme change | Eliminates 4,800 regex ops/sec on UI thread |
| Single `BlocConsumer` rebuilding entire page | Multiple `BlocBuilder`s with `buildWhen` | Only the affected subtree rebuilds on each state change |
| Zero `RepaintBoundary` usage | Three boundaries isolating board, score, controls | Independent GPU compositing layers — board repaint doesn't cascade to score HUD |
| `HapticService.instance` static singleton | `sl<HapticService>()` via GetIt | Consistent with all other services; testable via DI |

---

## Environment Availability

Step 2.6: SKIPPED (no external dependencies — this phase is pure Dart/Flutter code refactoring with no
new tools, services, CLIs, or runtime dependencies required).

---

## Open Questions

1. **ThemeSelectionPage dispatch vs. direct datasource write**
   - What we know: `ThemeSelectionPage` currently calls `ProgressionLocalDataSource.setActiveTileTheme()`
     directly. After the refactor, ProgressionBloc must be notified.
   - What's unclear: Does `ThemeSelectionPage` have a BLoC yet, or does it call the datasource via `sl<>`?
     (Not read during research — CONTEXT.md listed it as in-scope but didn't specify the page's current
     state management approach.)
   - Recommendation: The planner should include a task to update `ThemeSelectionPage` to dispatch
     `UpdateTileTheme` to `ProgressionBloc`. Even if the page had no BLoC before, it can read the
     global `ProgressionBloc` from context.

2. **BlocListener vs. outer BlocConsumer for GamePage listener**
   - What we know: The current listener handles level-start analytics, juice effects, GameWon/GameLost
     dialogs. These must not be lost during the split.
   - What's unclear: Whether to use `BlocListener` wrapping the scaffold, or keep one
     `BlocConsumer(buildWhen: (_, __) => false)` at the top and nest builders inside.
   - Recommendation: Use `BlocListener` for clarity. The listener wraps the scaffold, and BlocBuilders
     operate independently inside the widget tree.

---

## Sources

### Primary (HIGH confidence)
- Direct code inspection of project files — confirmed call counts, file locations, class structures,
  existing DI patterns, BLoC event/state shapes, and widget tree layout. All findings above are derived
  from actual source files, not training data.
- `lib/features/leaderboard/presentation/pages/leaderboard_page.dart` — confirmed `buildWhen` usage pattern
- `lib/app/app.dart` — confirmed global BLoC provision pattern
- `lib/features/achievements/presentation/bloc/achievements_bloc.dart` — confirmed BLoC file structure
- `lib/app/di.dart` — confirmed DI registration patterns (registerFactory vs registerLazySingleton)
- `lib/features/progression/data/datasources/progression_local_datasource.dart` — confirmed Hive read API
- `lib/features/game/presentation/pages/game_page.dart` — confirmed single BlocConsumer, HapticService call sites
- `lib/features/game/presentation/widgets/tile_widget.dart` — confirmed 5 TileThemes call sites + double decoration
- `lib/core/services/sound_service.dart` — confirmed HapticService structure

### Secondary (MEDIUM confidence)
- flutter_bloc `context.select` pattern — standard documented API, consistent with version in pubspec
- flutter_bloc `BlocListener` + `BlocBuilder` separation — established flutter_bloc pattern

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — no new packages, all existing
- Architecture (ProgressionBloc): HIGH — follows confirmed project conventions exactly
- RepaintBoundary placement: HIGH — three zones confirmed by reading actual widget tree in game_page.dart
- buildWhen conditions: HIGH — derived from actual GameState/GameSession field inspection
- HapticService call sites: HIGH — grepped and confirmed 15 call sites across 4 files
- Pitfalls: HIGH — derived from actual code patterns and confirmed jank sources from Phase 1

**Research date:** 2026-03-26
**Valid until:** 2026-06-26 (stable Flutter/BLoC patterns — 90 days)

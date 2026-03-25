# Architecture Research

**Domain:** Flutter mobile game — polish, performance, and store preparation layer on top of Clean Architecture + BLoC
**Researched:** 2026-03-25
**Confidence:** HIGH (grounded in existing codebase + official Flutter docs)

---

## System Overview

The v1.2 polish milestone does not introduce new feature modules. It augments three existing layers: the presentation tier, the core theme system, and the build/deployment pipeline. No domain or data layer changes are required.

```
┌────────────────────────────────────────────────────────────────┐
│                     STORE PIPELINE (NEW)                        │
│  fastlane/   screenshots/   metadata/   icons/  (outside lib/) │
└────────────────────────────────────────────────────────────────┘
                              |
┌────────────────────────────────────────────────────────────────┐
│                   PRESENTATION TIER (AUGMENTED)                 │
│                                                                  │
│  ┌───────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│  │  AnimationSys │  │ ThemeSystem  │  │  PerformanceWrapper  │ │
│  │  (per-widget) │  │ (app-level)  │  │  (dev-only overlay)  │ │
│  └───────┬───────┘  └──────┬───────┘  └──────────┬───────────┘ │
│          │                 │                      │             │
│  ┌───────▼─────────────────▼──────────────────────▼──────────┐ │
│  │               Existing Widget Tree                         │ │
│  │  GamePage / EndlessPage / HomeScreen / LevelsPage / …      │ │
│  └────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────┘
                              |
┌────────────────────────────────────────────────────────────────┐
│                   DOMAIN + DATA (UNCHANGED)                      │
│  GameEngine (pure static)  |  BLoC events/states               │
│  Repositories (Hive)       |  Firebase (optional)              │
└────────────────────────────────────────────────────────────────┘
```

---

## Component Responsibilities

| Component | Exists? | Responsibility | v1.2 Action |
|-----------|---------|----------------|-------------|
| `TileWidget` | Yes | Per-tile animations (merge, spawn, glow) | Audit; fix animation controller leak risk in `didUpdateWidget` |
| `GameBoard` | Yes | Board layout, empty cells | Add `RepaintBoundary` around board to isolate repaint from HUD |
| `ParticleEffect` | Yes | Bomb explosion particles via `CustomPaint` | Already well-isolated; verify `shouldRepaint` returns true only on progress change |
| `ScreenShake` | Yes | Camera shake on bomb/special | Review shake amplitude; ensure `GlobalKey` access is safe |
| `ComboOverlay` | Yes | Combo counter display | Audit rebuild scope |
| `ScorePopup` | Yes | Score gain floating text | Audit rebuild scope |
| `AppTheme` / `AppColors` | Yes | Global color/font constants | Refine color consistency across screens |
| `TileThemes` | Yes | Per-theme tile colors (reads Hive directly) | Isolate Hive read into a `ChangeNotifier` or BLoC state to avoid stale renders |
| `HapticService` | Yes (inline in GamePage) | Light haptic on swipe | Extract to `core/services/haptic_service.dart` for reuse |
| `PerformanceMonitorService` | No | Frame timing, jank detection | Create as dev-only service (no-ops in release) |
| `AppTransitions` | No | Route transition definitions for go_router | Create as `core/navigation/app_transitions.dart` |
| `ScreenshotDriver` | No | Integration test script for store screenshots | Create in `integration_test/screenshots/` |
| `fastlane/` | No | Deliver + Supply for store submission | Create in project root |

---

## Recommended Project Structure (new files only)

```
lib/
  core/
    navigation/
      app_transitions.dart    # CustomTransitionPage builders for go_router
    services/
      haptic_service.dart     # Extract from game_page.dart (already called HapticService.instance)
      performance_service.dart # Dev-only frame monitoring, no-ops in release
    theme/
      app_theme.dart          # MODIFY: add pageTransitionsTheme key
      app_colors.dart         # MODIFY: audit consistency pass

  features/
    game/
      presentation/
        widgets/
          game_board.dart     # MODIFY: wrap in RepaintBoundary
          tile_widget.dart    # MODIFY: fix animation controller didUpdateWidget race

integration_test/
  screenshots/
    screenshot_test.dart      # Drive app to key screens, capture golden frames

fastlane/
  Appfile                     # App identifiers
  Fastfile                    # Lanes: screenshots, beta, release
  metadata/
    en-US/
      title.txt
      short_description.txt
      full_description.txt
      keywords.txt
      release_notes/
        default.txt
  screenshots/
    android/                  # Device-framed PNGs
    ios/                      # Device-framed PNGs

assets/
  icon/
    icon.png                  # 1024x1024 source (already present)
```

---

## Architectural Patterns

### Pattern 1: RepaintBoundary Isolation for the Board

**What:** Wrap `GameBoard` (and each `TileWidget`) in `RepaintBoundary` so that HUD widgets (score display, power-up bar) do not trigger board repaints when they rebuild from BLoC state.

**When to use:** Any widget that animates at high frequency (60fps tile animations) must not be in the same repaint layer as widgets that update on game events.

**Trade-offs:** Slight GPU memory overhead per boundary. Acceptable here because the board is a fixed-size widget. Do not wrap every `TileWidget` individually — wrap the `GameBoard` container once, and let `TileWidget` manage its own `AnimationController` isolation via `SingleTickerProviderStateMixin`.

```dart
// game_board.dart — add RepaintBoundary at the board level
RepaintBoundary(
  child: GameBoard(board: board, isHammerMode: isHammerMode),
)
```

### Pattern 2: Route Transitions via AppTransitions Helper

**What:** Centralise all `go_router` `CustomTransitionPage` definitions in `core/navigation/app_transitions.dart`. Each route in `router.dart` calls a named builder.

**When to use:** Ensures consistent transition style across all screens without duplicating `transitionsBuilder` closures in `router.dart`.

**Trade-offs:** Adds one indirection file. Worth it because router.dart is already long and transitions are a cross-cutting concern.

```dart
// core/navigation/app_transitions.dart
class AppTransitions {
  static Page<T> fade<T>({required Widget child, required LocalKey key}) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  static Page<T> slideUp<T>({required Widget child, required LocalKey key}) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, _, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}
```

Use `AppTransitions.fade` for lateral navigation (zone → level list), `AppTransitions.slideUp` for modal-style screens (game page, paywall).

### Pattern 3: Dev-Only PerformanceService with Release No-Ops

**What:** A service registered in GetIt that wraps Flutter's `PerformanceOverlay` flag and optionally logs frame timing to the console. In release builds all methods are stubs.

**When to use:** During the performance polish phase to surface jank without requiring DevTools open on a physical device. Exposes a toggle in the existing dev options page (`/dev`).

**Trade-offs:** Adds a small class; negligible cost. Do not use Firebase Performance SDK for this — it instruments network calls, not rendering frames. Use `SchedulerBinding.instance.addTimingsCallback` in debug/profile builds instead.

```dart
// core/services/performance_service.dart
class PerformanceService {
  void initialize() {
    assert(() {
      SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
      return true;
    }());
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      final ms = t.totalSpan.inMilliseconds;
      if (ms > 16) debugPrint('JANK: ${ms}ms frame');
    }
  }

  // Release build: no-op
  void dispose() {
    assert(() {
      SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
      return true;
    }());
  }
}
```

Register in `di.dart`: `sl.registerLazySingleton<PerformanceService>(() => PerformanceService());`

### Pattern 4: TileThemes Reactive via BLoC/Notifier

**What:** `TileThemes` currently reads Hive directly on every `tileColor()` call using a regex parse of raw JSON. This is fragile and cannot trigger a rebuild when the theme changes.

**When to use:** Required for the theme-change UX to reflect immediately without app restart.

**Do this instead:** Have `ProgressionBloc` expose the active `TileTheme` in its state. `TileWidget` receives the theme as a constructor parameter from its parent, not via a global static call.

```dart
// tile_widget.dart — constructor change
class TileWidget extends StatefulWidget {
  final Tile tile;
  final double cellSize;
  final TileTheme tileTheme;  // injected, not looked up globally
  ...
}
```

`GameBoard` pulls the theme from `context.select` on `ProgressionBloc` and passes it down. This eliminates the Hive read per-frame and makes theme switching instant.

---

## Data Flow

### Tile Animation Flow

```
SwipeMade (event)
    |
GameBloc._onSwipeMade
    |
GameEngine.moveTiles() → sets tile.wasMerged / wasSpawned flags on Board
    |
GamePlaying (state emitted)
    |
BlocBuilder<GameBloc, GameState> in game_page.dart
    |
GameBoard rebuilds → TileWidget.didUpdateWidget fires
    |
AnimationController.forward(from: 0.0) triggered on affected tiles
    |
AnimatedBuilder drives scale + opacity + glow (60fps, isolated in RepaintBoundary)
```

### Theme Change Flow (current — broken)

```
User selects theme in progression screen
    → ProgressionBloc saves to Hive
    → TileThemes._activeTheme() re-reads Hive on next render
    → No active rebuild triggered (stale theme until page is rebuilt)
```

### Theme Change Flow (target — v1.2)

```
User selects theme
    → ProgressionBloc emits new state with activeTileTheme
    → GamePage / EndlessPage: context.select picks up activeTileTheme
    → GameBoard passes theme down to TileWidget
    → TileWidget rebuilds with correct colors immediately
```

### Screen Transition Flow

```
User action (tap level, tap back)
    → go_router.push/pop
    → AppTransitions.fade or slideUp builder invoked
    → CustomTransitionPage drives FadeTransition/SlideTransition
    → 220–280ms duration, easeOutCubic curve
```

### Store Pipeline Flow

```
Developer runs: fastlane ios screenshots (or android)
    → integration_test/screenshots/screenshot_test.dart drives app
    → WidgetController navigates to key screens
    → takeScreenshot() captures PNG per device size
    → fastlane frameit composites device frames
    → fastlane deliver / supply uploads to App Store Connect / Play Console
```

---

## Integration Points

### Existing Components to Modify

| Component | File | Change |
|-----------|------|--------|
| `GameBoard` | `lib/features/game/presentation/widgets/game_board.dart` | Wrap with `RepaintBoundary`; pass `TileTheme` down |
| `TileWidget` | `lib/features/game/presentation/widgets/tile_widget.dart` | Remove `TileThemes` static call; accept `TileTheme` param; audit `didUpdateWidget` for double-trigger |
| `router.dart` | `lib/app/router.dart` | Replace default page builders with `AppTransitions` builders |
| `app_theme.dart` | `lib/core/theme/app_theme.dart` | Add `pageTransitionsTheme` with `ZoomPageTransitionsBuilder` (Android) and `CupertinoPageTransitionsBuilder` (iOS) as fallback for non-custom routes |
| `di.dart` | `lib/app/di.dart` | Register `PerformanceService` as lazy singleton |
| `game_page.dart` | `lib/features/game/presentation/pages/game_page.dart` | Extract inline `HapticService` reference to `sl<HapticService>()` |

### New Components to Create

| Component | File | Notes |
|-----------|------|-------|
| `AppTransitions` | `lib/core/navigation/app_transitions.dart` | Pure static helpers; no DI needed |
| `HapticService` | `lib/core/services/haptic_service.dart` | `HapticService.instance` already called — just formalise the class and register in DI |
| `PerformanceService` | `lib/core/services/performance_service.dart` | Debug/profile only via `assert` guards |
| `screenshot_test.dart` | `integration_test/screenshots/screenshot_test.dart` | Not a unit test; drives the app for store screenshots |
| `fastlane/` | Project root | Appfile, Fastfile, metadata structure |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| `ProgressionBloc` ↔ `TileWidget` | `context.select` in `GameBoard`; theme passed as constructor param | Do not call `TileThemes` static inside `TileWidget` after this change |
| `GameBloc` ↔ `ParticleEffect` | `GlobalKey<ParticleEffectState>` in `GamePage`; `.explode()` called imperatively | Acceptable for fire-and-forget effects; no BLoC state needed |
| `GameBloc` ↔ `ScreenShake` | Same GlobalKey pattern as particles | Acceptable |
| `PerformanceService` ↔ `DevPage` | `sl<PerformanceService>().toggle()` from dev options toggle | Dev page already exists at `/dev` |

---

## Build Order for v1.2

The following order respects dependencies and avoids blocking work:

1. **Performance audit first** — set up `PerformanceService`, run on physical device, identify actual jank sources before fixing hypothetical ones. This prevents wasted effort polishing things that are already fast.

2. **TileTheme refactor** — changes `TileWidget` constructor, which `GameBoard` depends on. Must be done before any visual theme work so theme changes render correctly during QA.

3. **RepaintBoundary + animation audit** — wrap board; fix `didUpdateWidget` race in `TileWidget`; verify `shouldRepaint` on `ParticleEffect` and `_RadialPatternPainter`. Depends on TileTheme refactor being complete so TileWidget signature is stable.

4. **Route transitions** — create `AppTransitions`, update `router.dart`. Independent of game widget changes; can be done in parallel with step 3.

5. **Visual design pass** — refine `AppColors`, `AppTheme`, `TileThemes` palettes, typography. Depends on TileTheme refactor (step 2) so color changes reflect immediately.

6. **UX flow and usability fixes** — navigation improvements, onboarding clarity. Depends on transitions (step 4) being in place so screens feel complete.

7. **Store preparation** — screenshot driver, fastlane setup, metadata copy, icon finalisation. Depends on visual design (step 5) being complete so screenshots capture the polished state.

---

## Anti-Patterns

### Anti-Pattern 1: Animating Inside BlocBuilder Directly

**What people do:** Trigger `AnimationController.forward()` inside a `BlocBuilder` callback.
**Why it's wrong:** `BlocBuilder` can rebuild multiple times from the same state (e.g., during `didUpdateWidget`). The animation will replay unexpectedly, and the controller lifecycle is not tied to widget lifecycle correctly.
**Do this instead:** Trigger animations in `didUpdateWidget` by comparing the previous and new `Tile.wasMerged` / `Tile.wasSpawned` flags, which is what the existing code already does. Keep this pattern. The risk is a double-trigger if BLoC emits the same state twice — guard with `!oldWidget.tile.wasMerged && widget.tile.wasMerged` (already present, verify it holds).

### Anti-Pattern 2: Calling TileThemes.tileColor() on Every Build

**What people do:** Call the `TileThemes` static method inside `_tileDecoration()`, which is called during every `build()` pass.
**Why it's wrong:** It opens a Hive box and runs a regex match per tile per frame. With 16 tiles animating at 60fps this is ~960 regex operations/second.
**Do this instead:** Pass `TileTheme` as a constructor parameter resolved once per `GameBoard` rebuild from `ProgressionBloc` state. Cache in `GameBoard`'s `build` method and pass down.

### Anti-Pattern 3: Using Firebase Performance for UI Jank Monitoring

**What people do:** Add `firebase_performance` package to track slow rendering.
**Why it's wrong:** Firebase Performance traces HTTP requests and method traces, not UI frame timing. It would add ~2MB binary size for no rendering benefit.
**Do this instead:** Use `SchedulerBinding.addTimingsCallback` in debug/profile builds (zero cost in release).

### Anti-Pattern 4: Generating Store Screenshots Manually

**What people do:** Take manual screenshots on a physical device for each device size, then add device frames in Photoshop.
**Why it's wrong:** Any visual change requires the entire process again. Impossible to maintain for 6+ required device sizes (iPhone 6.9", 6.5", iPad, Pixel, etc.).
**Do this instead:** `integration_test` driver + `fastlane frameit` generates all sizes automatically. One `flutter test integration_test/screenshots/screenshot_test.dart` run per platform produces all assets.

---

## Scaling Considerations

This is a single-player mobile game. Scaling concerns are device performance, not server scale.

| Concern | Current (v1.1) | v1.2 Target | Notes |
|---------|----------------|-------------|-------|
| Frame rate | Unknown — no monitoring | 60fps on mid-range devices (e.g. Pixel 4a, iPhone 12 mini) | Profile on these specific devices |
| Memory | No measurement | Board + 16 TileWidgets < 50MB | `ParticleEffect` creates 30 `_Particle` objects per explosion; GC pressure is low |
| Build time | Standard | No change | RepaintBoundary adds negligible layout cost |
| App binary size | ~35MB (estimated with all Firebase deps) | No change from polish work | Defer size audit to post-launch |

---

## Sources

- Flutter performance profiling: https://docs.flutter.dev/perf/ui-performance
- RepaintBoundary API docs: https://api.flutter.dev/flutter/widgets/RepaintBoundary-class.html
- go_router CustomTransitionPage: https://pub.dev/documentation/go_router/latest/topics/Transition%20animations-topic.html
- Fastlane for Flutter guide: https://blog.logrocket.com/fastlane-flutter-complete-guide/
- Flutter screenshot automation (golden + supply): https://medium.com/@mregnauld/generate-screenshots-for-a-flutter-app-with-golden-testing-and-upload-them-to-the-stores-1-2-45f8df777aef
- SchedulerBinding.addTimingsCallback: Flutter SDK source (SchedulerBinding class)

---

*Architecture research for: Infinite 2048 v1.2 — polish, performance, store preparation*
*Researched: 2026-03-25*

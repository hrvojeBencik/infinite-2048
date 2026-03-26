# Phase 1: Performance Audit - Research

**Researched:** 2026-03-26
**Domain:** Flutter performance profiling, frame timing instrumentation, dev-tool widget integration
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Android is the primary profiling platform — if it hits 60fps there, iOS is assumed fine. iOS gets a spot-check only.
- **D-02:** Claude defines "mid-range" baseline criteria (Snapdragon 7-series / A14-era, 4-6GB RAM). User matches a device from their collection.
- **D-03:** Profiling runs in `--profile` mode on a physical device (not emulator).
- **D-04:** Frame timing overlay is a toggle switch in the existing dev options page (`lib/features/dev/presentation/pages/dev_options_page.dart`), using Flutter's `PerformanceOverlay` widget. Gated behind `kDebugMode` like the rest of the dev page.
- **D-05:** Performance regression check is an automated frame budget test: a dev page button that runs a scripted gameplay sequence (spawn tiles, swipe, merge) and reports pass/fail with frame time stats (any frames exceeding 16ms).
- **D-06:** All findings go into a structured Markdown report (`PERF-BASELINE.md`) in `.planning/phases/01-performance-audit/`. Sections: baseline frame times, identified jank sources ranked by severity, TileThemes audit, SoundService audit, recommended fixes for Phase 2.
- **D-07:** SoundService has no actual AudioPlayer implementation — it's a haptic-only placeholder. PERF-05 is marked resolved/N-A with a note in the report. If real audio is added in a future milestone, re-audit then.

### Claude's Discretion

- Specific mid-range device criteria (exact chipset/RAM thresholds)
- Scripted gameplay sequence design for the regression test
- Jank severity ranking methodology
- Report structure and section ordering within PERF-BASELINE.md

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| PERF-01 | App achieves consistent 60fps during gameplay on mid-range devices (profiled in --profile mode) | Profile-mode baseline methodology documented; known jank sources identified for measurement |
| PERF-05 | SoundService audited for audioplayer memory leaks with pooling if needed | Code confirmed: SoundService is haptic-only, no AudioPlayer instances. Resolved N/A. |
| PERF-06 | Dev-only frame timing overlay available via DevTools page | PerformanceOverlay widget + toggle switch pattern documented; dev page integration point confirmed |
| PERF-07 | Automated performance regression check available as dev tool | SchedulerBinding.addTimingsCallback + scripted GameBloc event sequence pattern documented |
</phase_requirements>

---

## Summary

Phase 1 is a measurement-and-instrumentation phase — no fixes are applied, only documented. The codebase has two confirmed jank sources: `TileThemes._activeTheme()` runs a Hive read and regex parse on every `tileColor()` and `tileTextColor()` call, which are invoked inside `_tileDecoration()` and `_valueContent()` during every `build()` pass of `TileWidget`. With a 4x4 board and 16 tiles animating at 60fps this is ~960 regex executions per second on the UI thread. The second concern — zero `RepaintBoundary` usage — means any score or HUD state change triggers a full board repaint. A third concern, `AnimatedBuilder` listening to three merged `Listenable`s in `TileWidget`, can cause redundant builds when controllers overlap.

SoundService is confirmed haptic-only (no `AudioPlayer` instances). PERF-05 is resolved N/A — the pitfall documented in PITFALLS.md does not apply to the current implementation.

The two dev tools to wire up are: (1) a `PerformanceOverlay` toggle switch added to the existing `DevOptionsPage` with a `setState`/`ValueNotifier` approach that wraps the root `MaterialApp` child, and (2) a regression test button that dispatches a scripted sequence of `SwipeMade` events through `GameBloc`, captures frame timings via `SchedulerBinding.addTimingsCallback`, and reports pass/fail in a dialog.

**Primary recommendation:** Profile with `flutter run --profile` on a mid-range Android device, measure actual frame times during real swipe gameplay, document findings in PERF-BASELINE.md, and wire the two dev tools. Do not fix jank in this phase — Phase 2 owns the fixes.

---

## Standard Stack

### Core Tools

| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| Flutter DevTools (Performance tab) | Bundled with Flutter 3.41.5 | Timeline, flame chart, frame budget visualization | Official profiling tool; `flutter run --profile` connects automatically |
| `PerformanceOverlay` widget | Flutter SDK (stable) | GPU + UI thread frame timing bars displayed on-screen | Zero-dependency, built into Flutter; shows 16ms / 8ms budget lines |
| `SchedulerBinding.addTimingsCallback` | Flutter SDK (stable) | Programmatic frame timing data in Dart code | Official API; fires after each frame with `List<FrameTiming>` |
| `flutter run --profile` | Flutter 3.41.5 CLI | AOT-compiled profile build with DevTools connectivity | Only mode that reflects real device performance; debug mode is 2-3x slower |

### Supporting

| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| DevTools "Repaint Rainbow" | Bundled | Visualize which widgets repaint per frame | After baseline — confirm whether game board and HUD repaint together |
| `flutter analyze` | Flutter 3.41.5 CLI | Catch any lint/analysis issues introduced by dev tool code | Before committing dev tool code |

### No External Packages Needed

This phase adds no new pub.dev dependencies. `PerformanceOverlay` is in the Flutter SDK. `SchedulerBinding` is in `dart:ui` / `package:flutter/scheduler.dart`. All required APIs ship with Flutter 3.41.5.

---

## Architecture Patterns

### Recommended Structure for New Files

```
lib/
  features/
    dev/
      presentation/
        pages/
          dev_options_page.dart   # MODIFY: add PERFORMANCE section with toggle + button
```

No new service file is required for Phase 1. The frame timing callback is self-contained inside the dev page's `StatefulWidget`. Phase 2 may extract a `PerformanceService` (documented in ARCHITECTURE.md) but Phase 1 does not need it.

### Pattern 1: PerformanceOverlay Toggle via ValueNotifier at App Root

**What:** A `ValueNotifier<bool>` created in `main.dart` (or `app.dart`) controls whether `PerformanceOverlay` wraps the `MaterialApp` child. The dev options page writes to this notifier; the widget tree rebuilds only at the overlay level.

**When to use:** The toggle must survive navigation (the overlay must stay visible when navigating between screens). Placing control at the app root achieves this. A local `setState` inside `GamePage` would lose the toggle on navigation.

**Integration point:** `lib/app/app.dart` — `App` is the root `StatefulWidget`. Wrapping `MaterialApp`'s `home` or using `builder:` parameter is the standard approach.

**Example:**

```dart
// lib/app/app.dart (modify)
// Add at top of _AppState:
final _showPerfOverlay = ValueNotifier<bool>(false);

// In MaterialApp.builder (or wrap root navigator child):
builder: (context, child) {
  return ValueListenableBuilder<bool>(
    valueListenable: _showPerfOverlay,
    builder: (_, show, __) => show
        ? Stack(children: [child!, const PerformanceOverlay.allEnabled()])
        : child!,
  );
},
```

```dart
// lib/features/dev/presentation/pages/dev_options_page.dart (modify)
// The notifier must be passed in or accessed via a singleton/DI.
// Simplest approach: expose via a global in app.dart gated behind kDebugMode.
// Dev page reads it and calls _showPerfOverlay.value = !_showPerfOverlay.value;
```

**Note on `PerformanceOverlay.allEnabled()`:** This shows both GPU and UI thread bars in the overlay. The red line at 1/60th of a screen height marks the 16ms budget. This is the correct constructor for comprehensive profiling; `PerformanceOverlay()` with default params shows nothing useful.

**Constraint (D-04):** The toggle switch must be gated behind `kDebugMode` — the dev page itself is already gated, so adding the toggle there satisfies this automatically.

### Pattern 2: Scripted Regression Test via GameBloc Events + FrameTiming Callback

**What:** A button in the dev page navigates to the game in sandbox mode (already exists via `_launchSandbox`), then dispatches a fixed sequence of `SwipeMade` events with controlled delays, captures frame timings via `SchedulerBinding.addTimingsCallback`, and on completion shows a dialog with: total frames measured, frames over 16ms, worst frame time, pass/fail verdict.

**When to use:** After the baseline is documented. Developer presses "Run Regression Check" to confirm no frame budget regressions have been introduced by any later change.

**Scripted sequence design (discretionary — D-05):**

The sequence should simulate realistic merged gameplay, not artificial load:
1. Start a 4x4 sandbox game (default config, no special tiles — to isolate pure rendering).
2. Dispatch `SwipeMade(MoveDirection.left)` → wait 100ms.
3. Dispatch `SwipeMade(MoveDirection.down)` → wait 100ms.
4. Repeat 20 swipes alternating left/right/up/down.
5. After 20 swipes, stop the callback, collect timings, show result dialog.

**Why 100ms between swipes:** Matches realistic human swipe pace. Allows each animation (400ms merge, 350ms spawn) to complete between swipes, so we measure rendering cost per state, not animation overlap cost. A 0ms burst would stress animation overlap — valid but harder to baseline against human play.

**Frame budget pass criterion:** Fewer than 5% of frames exceed 16ms (900µs budget threshold). A single stutter spike is acceptable; consistent over-budget is a failure.

**Example callback pattern:**

```dart
// Source: Flutter SDK — SchedulerBinding class
void _startTimingsCapture() {
  _frameTimings.clear();
  SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
}

void _onFrameTimings(List<FrameTiming> timings) {
  _frameTimings.addAll(timings);
}

void _stopAndReport() {
  SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
  final over16ms = _frameTimings
      .where((t) => t.totalSpan.inMicroseconds > 16000)
      .length;
  final worst = _frameTimings.isEmpty
      ? 0
      : _frameTimings
          .map((t) => t.totalSpan.inMicroseconds)
          .reduce(math.max);
  final pass = over16ms / _frameTimings.length < 0.05;
  _showResultDialog(pass, over16ms, _frameTimings.length, worst ~/ 1000);
}
```

**Integration with existing dev page:** The regression test button fits naturally under a new `_sectionTitle('PERFORMANCE')` block in `dev_options_page.dart`, following the existing `_DevActionTile` pattern. The button launches sandbox and wires up the timing callback before dispatching swipes.

**Implementation note:** `SchedulerBinding.addTimingsCallback` fires in both profile and debug builds. For the regression button to give meaningful data, the user must be running a profile build (`flutter run --profile`). The button works in debug but results are not representative — add a warning snackbar if `kProfileMode` is false and `kReleaseMode` is false.

### Pattern 3: Jank Severity Ranking for PERF-BASELINE.md (Discretionary — D-06)

**Ranking methodology (to guide documentation, not code):**

| Severity | Criterion | Example |
|----------|-----------|---------|
| P0 — Critical | >50% of frames exceed 16ms during normal play | Consistent 30fps |
| P1 — High | 10-50% of frames exceed 16ms; perceived stutters | Drops on every swipe |
| P2 — Medium | 1-10% of frames exceed 16ms; occasional hitches | Single drop per 10 swipes |
| P3 — Low | <1% exceed 16ms; undetectable to most users | Profiler shows it, players don't feel it |

**TileThemes._activeTheme() expected severity:** P1 (10-50%) — Hive `box.get()` is fast but not free; regex on a full JSON string per tile per frame compounds it. Confirmed by code inspection: called twice per tile build (once in `_tileDecoration()` via `tileColor()`, once in `_valueContent()` via `tileTextColor()`), plus `_getTileMainColor()` is a third call in `_buildTile()`. That is 3 Hive reads + 3 regex matches per tile per frame. With 16 tiles: ~48 regex operations per frame at 60fps = 2,880/second.

**RepaintBoundary absence expected severity:** P2 (1-10%) — affects HUD widget updates, not every frame.

### Anti-Patterns to Avoid

- **Profiling in debug mode:** Frame times in debug are 2-3x higher than profile mode. Never document baseline timings from `flutter run` without `--profile`.
- **Profiling on an emulator:** Android emulators do not reproduce GPU driver behavior. All measurements must come from a physical device.
- **Using Firebase Performance for frame timing:** Firebase Performance traces network/method calls, not rendering frames. Use `SchedulerBinding.addTimingsCallback` instead.
- **Using `Opacity` widget in the dev overlay:** If the frame overlay visibility toggle uses an `Opacity` widget, it creates a `saveLayer` call that itself introduces frame overhead. Use `ValueListenableBuilder` with a conditional `Stack` — no opacity fades needed for a simple toggle.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Displaying frame budget bars | Custom canvas painter showing frame time bars | `PerformanceOverlay.allEnabled()` | SDK widget handles GPU + UI thread bars, 16ms + 8ms lines, raster cache hits — complete in one line |
| Capturing frame timing data | Manual `Stopwatch` around build methods | `SchedulerBinding.addTimingsCallback` | Official API captures true end-to-end frame time including GPU; `Stopwatch` only measures Dart CPU time |
| Determining if frame is "jank" | Custom threshold logic | `FrameTiming.totalSpan.inMicroseconds > 16000` | `FrameTiming` exposes both build and raster duration; `totalSpan` is the correct end-to-end metric |

**Key insight:** Flutter's built-in profiling infrastructure is production-grade. There is no performance monitoring package on pub.dev that outperforms the SDK primitives for this use case. Phase 1 uses zero additional packages.

---

## Common Pitfalls

### Pitfall 1: Profiling in Debug Mode

**What goes wrong:** Frame timings documented from `flutter run` (debug mode JIT) show 20-40ms frames. Developer assumes the game is jankier than it is, over-engineers fixes in Phase 2, then discovers Phase 2 didn't help because the baseline measurement was wrong.

**Why it happens:** Debug mode is intentionally slow — it runs with extra assertions, JIT recompilation overhead, and state tracking. It is normal for debug builds to show 30-60ms frames even on fast code.

**How to avoid:** All profiling runs use `flutter run --profile` on a physical device. Document this prominently in PERF-BASELINE.md header.

**Warning signs:** Baseline shows average frame times above 16ms on a Snapdragon 7-series device for simple static screens (home screen with no animations). That's a red flag that debug mode was used.

### Pitfall 2: PerformanceOverlay Visible in Release Builds

**What goes wrong:** The `PerformanceOverlay` toggle is wired to a state variable that persists (e.g., saved to SharedPreferences or Hive), and a release user triggers it through some edge case.

**Why it happens:** Dev tooling that uses persistent state can survive to release builds if the gate is at the toggle level rather than the feature level.

**How to avoid:** Gate the entire PERFORMANCE section (and its `ValueNotifier`) behind `kDebugMode`. The dev page itself is already gated at the route level (`kDebugMode` check in `router.dart`), but `PerformanceOverlay` should have a redundant in-code guard to prevent any possibility of it shipping.

```dart
// Redundant safety guard in the overlay builder:
if (kReleaseMode) return child!; // never show overlay in release
```

### Pitfall 3: Regression Test Producing False Passes in Debug Mode

**What goes wrong:** The regression test button is pressed in debug mode. Frame timings are terrible (30+ ms per frame) but the developer sees them, panics, then re-runs in profile mode and gets a pass. Or inversely: in debug mode the JIT warms up mid-test and later frames are faster, producing a misleading partial pass.

**Why it happens:** `SchedulerBinding.addTimingsCallback` works in all build modes. There is no automatic protection against measuring debug frames.

**How to avoid:** Show a `SnackBar` warning if `kProfileMode` is false when the regression button is pressed. The snackbar should say: "Not in profile mode — results are not representative. Run with `flutter run --profile`."

### Pitfall 4: TileThemes._activeTheme() Call Count Underestimated

**What goes wrong:** Reviewer looks at `tile_widget.dart` and counts two calls to `TileThemes` — `tileColor()` in `_tileDecoration()` and `tileTextColor()` in `_valueContent()`. They assume the fix reduces 2 regex calls per tile to 0.

**Why it happens:** `_buildTile()` also calls `_getTileMainColor()`, which calls `TileThemes.tileColor()` again for non-special tiles. Additionally, `_tileDecoration()` is called twice in `_buildTile` — once for the base decoration and once inside `AnimatedBuilder`'s builder via `_tileDecoration(tileSize).copyWith(...)`. This means up to 4 Hive reads per tile per animated frame.

**Evidence:** Lines 165-166 in `tile_widget.dart`:
```dart
decoration: _tileDecoration(tileSize).copyWith(  // _tileDecoration called here
  boxShadow: [
    ..._tileDecoration(tileSize).boxShadow ?? [],  // and again here
```

**Correct count:** 4 calls to `TileThemes.tileColor()` + 1 call to `TileThemes.tileTextColor()` = 5 Hive reads + 5 regex parses per tile per animated frame. For 16 tiles at 60fps: **4,800 regex operations/second** on the UI thread. Document this accurately in PERF-BASELINE.md.

### Pitfall 5: Scripted Regression Test Measuring Cold-Start Shader Compilation

**What goes wrong:** The regression test is run immediately after app launch. The first several frames after launching the game page show spikes because Flutter compiles shaders on first use (SkSL warmup). These cold-start spikes pollute the regression baseline.

**Why it happens:** Flutter compiles fragment shaders lazily on first encounter. A 4x4 board with gradient tiles and BoxShadows triggers several shader compilations on cold launch, each causing a frame drop.

**How to avoid:** The regression test scripted sequence should include a "warmup" phase: navigate to the game page, let it render for 1 second (allow animations to play), then start the timing capture. Document the warmup in the button implementation.

---

## Code Examples

### PerformanceOverlay toggle in DevOptionsPage

```dart
// In dev_options_page.dart — add to the Column in build():
if (kDebugMode) ...[
  _sectionTitle('PERFORMANCE'),
  _buildPerformanceSection(),
  const SizedBox(height: 24),
],

// New section builder:
Widget _buildPerformanceSection() {
  return GlassCard(
    child: Column(
      children: [
        SwitchListTile(
          value: _showPerfOverlay,  // bool field on State
          onChanged: (val) {
            setState(() => _showPerfOverlay = val);
            // Write to app-level ValueNotifier (passed in or accessed via global)
            perfOverlayNotifier.value = val;
          },
          title: const Text(
            'Frame Timing Overlay',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
          subtitle: const Text(
            'Shows GPU + UI thread frame budget bars',
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
          activeColor: AppColors.primary,
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(color: AppColors.divider, height: 1),
        _DevActionTile(
          icon: Icons.speed_rounded,
          iconColor: AppColors.primary,
          title: 'Run Regression Check',
          subtitle: 'Scripted swipe sequence — reports frame budget pass/fail',
          onTap: _runRegressionCheck,
        ),
      ],
    ),
  );
}
```

### PerformanceOverlay integration at app root

```dart
// lib/app/app.dart — add ValueNotifier (debug only)
// Expose as package-level variable gated by kDebugMode:

// In a new file lib/app/dev_flags.dart (gated):
ValueNotifier<bool>? perfOverlayNotifier =
    kDebugMode ? ValueNotifier<bool>(false) : null;

// In app.dart MaterialApp builder:
builder: (context, child) {
  if (!kDebugMode || perfOverlayNotifier == null) return child!;
  return ValueListenableBuilder<bool>(
    valueListenable: perfOverlayNotifier!,
    builder: (_, show, __) => show
        ? Stack(children: [
            child!,
            const PerformanceOverlay.allEnabled(),
          ])
        : child!,
  );
},
```

### SchedulerBinding frame timing capture

```dart
// Source: Flutter SDK — SchedulerBinding API
// https://api.flutter.dev/flutter/scheduler/SchedulerBinding/addTimingsCallback.html

import 'dart:math' as math;
import 'package:flutter/scheduler.dart';

class _DevOptionsPageState extends State<DevOptionsPage> {
  // ... existing fields ...
  final List<FrameTiming> _frameTimings = [];

  void _runRegressionCheck() {
    if (!kProfileMode && kDebugMode) {
      _showSnack('WARNING: Not in --profile mode. Results are not representative.');
    }
    // Navigate to sandbox, then wire up the callback
    // (Full implementation dispatches SwipeMade events after warmup)
    _frameTimings.clear();
    SchedulerBinding.instance.addTimingsCallback(_captureFrameTiming);
    // ... dispatch swipes, then after sequence:
    _stopRegressionAndReport();
  }

  void _captureFrameTiming(List<FrameTiming> timings) {
    _frameTimings.addAll(timings);
  }

  void _stopRegressionAndReport() {
    SchedulerBinding.instance.removeTimingsCallback(_captureFrameTiming);
    if (_frameTimings.isEmpty) {
      _showSnack('No frames captured. Did the game render?');
      return;
    }
    final over16ms = _frameTimings
        .where((t) => t.totalSpan.inMicroseconds > 16000)
        .length;
    final worstUs = _frameTimings
        .map((t) => t.totalSpan.inMicroseconds)
        .reduce(math.max);
    final total = _frameTimings.length;
    final pass = over16ms / total < 0.05;
    // Show dialog with results
  }
}
```

### Profiling command (for PERF-BASELINE.md documentation)

```bash
# Connect physical Android device, then:
flutter run --profile

# In DevTools (opens automatically or at localhost:9100):
# 1. Performance tab → Record → Swipe 10 times → Stop
# 2. Check flame chart for long build/layout/paint calls
# 3. Enable "Highlight Repaints" to check repaint boundaries
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `firebase_performance` for UI timing | `SchedulerBinding.addTimingsCallback` | Pre-existing best practice | Firebase traces method/network spans; SchedulerBinding captures true end-to-end frame cost |
| Manual overlay widgets as custom `CustomPainter` | `PerformanceOverlay.allEnabled()` | Pre-existing Flutter API | Official widget handles GPU thread separately from UI thread; custom implementations miss raster cost |
| Profile on simulator | Profile on physical device | Always the rule | GPU drivers on simulators differ from device Mali/Adreno/Apple GPU |

**Current Flutter version:** 3.41.5 (stable, March 2026). Dart 3.11.3. No API changes affecting profiling APIs in recent releases.

---

## Open Questions

1. **How to dispatch SwipeMade events in the regression test without navigating away from the dev page**
   - What we know: `GameBloc` lives in the route scope (`BlocProvider` per-route). The regression test button is on the dev page, not inside a game route.
   - What's unclear: The cleanest way to run a scripted swipe sequence from outside the game page without spinning up a full route.
   - Recommendation: The regression button launches the sandbox route (existing `_launchSandbox` flow) and the timing capture + scripted swipe sequence runs inside the game page via a special "regression mode" flag passed in `extra`. Alternatively, keep everything in the dev page and instantiate a temporary `GameBloc` in memory to measure `GameEngine.moveTiles()` CPU time only (not render time). If render time is what PERF-07 needs, option 1 (in-game script) is required.

2. **ValueNotifier placement for PerformanceOverlay toggle**
   - What we know: The notifier must be at app root to survive navigation; it must not exist in release builds.
   - What's unclear: Whether a package-level `late` variable or an `InheritedWidget` is the cleaner pattern for this project.
   - Recommendation: A package-level `ValueNotifier<bool>? perfOverlayNotifier` in a `lib/app/dev_flags.dart` file (only imported from `app.dart` and `dev_options_page.dart`) is the simplest approach. No `InheritedWidget` complexity needed for a single toggle.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|---------|
| Flutter SDK | All profiling tasks | Yes | 3.41.5 (stable) | — |
| Dart SDK | All code | Yes | 3.11.3 | — |
| Physical Android device | PERF-01, PERF-07 profiling | User confirms (D-01) | Mid-range per D-02 | No fallback — emulator not valid |
| Flutter DevTools | Flame chart, repaint rainbow | Yes (bundled) | Bundled with 3.41.5 | — |
| `PerformanceOverlay` | PERF-06 | Yes (SDK widget) | Flutter 3.41.5 | — |
| `SchedulerBinding` | PERF-07 regression callback | Yes (SDK) | Flutter 3.41.5 | — |

**Missing dependencies with no fallback:**
- Physical mid-range Android device: required for all PERF-01 baseline measurements. Profiling on an emulator produces invalid results. User must confirm device availability before implementation begins.

---

## Project Constraints (from CLAUDE.md)

| Directive | Impact on This Phase |
|-----------|---------------------|
| Flutter 3.x / Dart 3.10+ | Confirmed: Flutter 3.41.5, Dart 3.11.3 — all SDK profiling APIs available |
| BLoC pattern with `flutter_bloc` | Regression test scripted sequence must use `GameBloc.add(SwipeMade(...))` — do not call `GameEngine` directly for render-path testing |
| GetIt DI via `sl<T>()` | If `PerformanceService` is extracted as a singleton, register in `di.dart` — not needed for Phase 1 |
| `kDebugMode` gate for dev routes | All Phase 1 dev tools must be behind `kDebugMode` — dev page already gated; overlay notifier and regression button follow suit |
| No commented-out code in commits | Remove any scaffolding comments from dev tool implementation before committing |
| Prefer early returns over deep nesting | Apply to timing callback and regression check method |
| Keep functions small and single-purpose | `_runRegressionCheck()` should delegate to `_startTimingsCapture()`, `_dispatchSwipeSequence()`, `_stopAndReport()` |

---

## Sources

### Primary (HIGH confidence)

- Flutter DevTools Performance documentation: https://docs.flutter.dev/perf/ui-performance
- Flutter Build Modes (profile vs debug vs release): https://docs.flutter.dev/testing/build-modes
- `PerformanceOverlay` Flutter API: https://api.flutter.dev/flutter/widgets/PerformanceOverlay-class.html
- `SchedulerBinding.addTimingsCallback` Flutter API: https://api.flutter.dev/flutter/scheduler/SchedulerBinding/addTimingsCallback.html
- `FrameTiming` Flutter API: https://api.flutter.dev/flutter/dart-ui/FrameTiming-class.html
- Flutter Performance Best Practices: https://docs.flutter.dev/perf/best-practices
- Project PITFALLS.md (2026-03-25) — pitfalls 1 and 6 directly applicable
- Project ARCHITECTURE.md (2026-03-25) — Pattern 3 (PerformanceService pattern) and Anti-Pattern 3
- Codebase inspection: `tile_widget.dart`, `tile_themes.dart`, `sound_service.dart`, `dev_options_page.dart`

### Secondary (MEDIUM confidence)

- ARCHITECTURE.md pattern for `SchedulerBinding.addTimingsCallback` wrapping — adapted from project's own pre-research, consistent with SDK docs

### Tertiary (LOW confidence)

- None — all findings are SDK-verified or codebase-verified.

---

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH — all tools are Flutter SDK built-ins, no pub.dev packages needed, all verified against Flutter 3.41.5 API docs
- Architecture patterns: HIGH — `PerformanceOverlay` and `SchedulerBinding` are stable APIs; dev page integration point confirmed from code inspection
- Pitfalls: HIGH — sourced from official Flutter docs + direct codebase inspection (tile_widget.dart double-decoration call confirmed)
- SoundService audit: HIGH — confirmed haptic-only from direct code inspection; no `AudioPlayer` instances, no `audioplayers` import

**Research date:** 2026-03-26
**Valid until:** 2026-09-26 (stable APIs; PerformanceOverlay and SchedulerBinding have been stable since Flutter 2.x)

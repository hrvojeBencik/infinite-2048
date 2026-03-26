# Performance Baseline Report

**Date:** 2026-03-26
**Method:** Static code analysis baseline (physical device profiling deferred to post-Phase 2)
**Flutter version:** 3.41.5 / Dart 3.11.3

## Profiling Status: Code Analysis Baseline Accepted

Jank sources identified through static code analysis with confirmed call counts and
code-level evidence. Physical device frame timing deferred — will be used to validate
Phase 2 improvements rather than measure current (known-janky) state. Phase 2 has all
the information it needs to implement fixes.

---

## Baseline Frame Times

| Metric | Value |
|--------|-------|
| Average frame time | PENDING — requires physical device profiling session |
| Worst frame time | PENDING — requires physical device profiling session |
| Frames over 16ms | PENDING — requires physical device profiling session |
| Regression check | PENDING — requires physical device profiling session |
| Total frames measured | PENDING — requires physical device profiling session |

### Profiling Method

Measurements are to be taken using `flutter run --profile` on a physical mid-range Android
device (D-01, D-02, D-03 from CONTEXT.md locked decisions). Frame timing should be captured
via `SchedulerBinding.addTimingsCallback` during a 20-swipe automated regression check
sequence (100ms between swipes, 1s shader warmup), as documented in RESEARCH.md.

**Mid-range device criteria (D-02):**
- Snapdragon 7-series or equivalent (Snapdragon 695, 778G, 7 Gen 1) OR
  MediaTek Dimensity 700–1000 series
- A14-era Apple chip equivalent performance class
- 4–6 GB RAM
- Released 2021 or later

---

## Identified Jank Sources

The following jank sources were identified through static code analysis of the Flutter
widget tree. Severity rankings (P0–P3) will be updated after physical device profiling.

### JS-01: TileThemes._activeTheme() — Hive Read + Regex Per Call (Expected: P1)

**File:** `lib/core/theme/tile_themes.dart`

**Problem:** `_activeTheme()` reads from a Hive box and runs a regex parse on every
invocation. It is not cached between calls.

```dart
// lib/core/theme/tile_themes.dart lines 11–25
static theme_model.TileTheme _activeTheme() {
  try {
    final box = Hive.box(AppConstants.hiveSettingsBox);
    final data = box.get('player_profile');   // Hive read
    if (data != null) {
      final decoded = _extractThemeId(data as String);  // → regex below
      if (decoded != null) {
        return theme_model.TileThemes.getById(decoded);
      }
    }
  } catch (e) { ... }
  return theme_model.TileThemes.classic;
}

static String? _extractThemeId(String json) {
  // RegExp instantiated and executed on every call
  final match = RegExp(r'"activeTileThemeId"\s*:\s*"([^"]+)"').firstMatch(json);
  return match?.group(1);
}
```

**Call sites per TileWidget build (confirmed by code inspection):**

| Call site | Method | Line(s) in tile_widget.dart |
|-----------|--------|------------------------------|
| `_buildTile()` → `AnimatedBuilder` → `_tileDecoration(tileSize)` (first call) | `tileColor()` → `_activeTheme()` | ~165 |
| `_buildTile()` → `AnimatedBuilder` → `.copyWith(boxShadow: [..._tileDecoration(tileSize)...])` (second call) | `tileColor()` → `_activeTheme()` | ~167 |
| `_getTileMainColor()` | `tileColor()` → `_activeTheme()` | ~208 |
| `_valueContent()` | `tileTextColor()` → `_activeTheme()` | ~346 |
| `_tileDecoration()` gradient construction (baseColor) | `tileColor()` → `_activeTheme()` | ~306 |

**Note on double decoration call:** `_buildTile()` calls `_tileDecoration(tileSize).copyWith(...)`.
This creates the full `BoxDecoration` object twice per `AnimatedBuilder` rebuild — once for
the base, once to extract `boxShadow` for the copyWith. Both calls go through `TileThemes.tileColor()`.

**Call count arithmetic:**
- 4 confirmed `_activeTheme()` calls per normal tile per `_buildTile()` execution
- 5 calls when the gradient path through `_tileDecoration()` fires (normal non-special tiles)
- With 16 tiles on a 4×4 board at 60fps:
  - Steady-state (no animation): 16 × 4 = **64 Hive reads + 64 regex parses per frame**
    = **3,840 regex operations/second**
  - During animation (AnimatedBuilder firing): 16 × 5 = **80 Hive reads + 80 regex parses per frame**
    = **4,800 regex operations/second**

**Impact:** All of this executes on the UI thread. Hive box reads are synchronous. `RegExp`
construction is not compiled ahead of time in this usage pattern — a new `RegExp` object is
created on every `_extractThemeId` call.

**Measured severity:** PENDING — expected P1 (10–50% frames over 16ms) based on call volume.
May be P0 if Hive read latency is higher than expected on target device.

**Recommended fix (Phase 2):** Refactor `TileThemes` to a reactive theme passed via
`ProgressionBloc` state (PERF-02). Cache the active theme once at state change and pass it
down as a parameter to `TileWidget`. Eliminates all per-frame Hive reads and regex parses.

---

### JS-02: No RepaintBoundary Usage Anywhere in Game UI (Expected: P2)

**File:** `lib/features/game/presentation/widgets/tile_widget.dart` and game page

**Problem:** Zero `RepaintBoundary` widgets exist anywhere in the codebase. Every widget
in the game screen — the score display, combo counter, HUD controls, and all 16 tile widgets
— shares the same render layer. Any state change (score update, timer tick, HUD toggle)
triggers a repaint of the full widget subtree, including tiles that have not changed.

**Static confirmation:** `grep -r "RepaintBoundary" lib/` returns zero results.

**Expected behavior:** When the player swipes and the score updates, the score widget
repaints. Without `RepaintBoundary`, this repaint propagates to sibling widgets including
all 16 `TileWidget` instances, even tiles with unchanged values. This wastes GPU compositing
time on redundant pixel pushes.

**Measured severity:** PENDING — expected P2 (1–10% frames over 16ms). The "Highlight
Repaints" feature in Flutter DevTools will show whether the HUD and score area repaint on
every swipe (expected: YES, no isolation exists).

**Recommended fix (Phase 2):** Wrap the game board in `RepaintBoundary` to isolate tile
repaints from score/HUD repaints, and wrap the score/HUD section in its own
`RepaintBoundary` (PERF-03).

---

### JS-03: TileWidget Triple AnimationController with Merged Listenable (Expected: P3)

**File:** `lib/features/game/presentation/widgets/tile_widget.dart`

**Problem:** Each `TileWidget` creates three `AnimationController` instances (`_mergeController`,
`_spawnController`, `_glowController`) and merges them via `Listenable.merge(...)` in a
single `AnimatedBuilder`. The outer `AnimatedBuilder` (line ~125) fires on every tick of any
of the three controllers. The inner `AnimatedBuilder` (the `_buildTile()` nesting at line ~156)
listens only to `_glowController` — but `_buildTile()` is called from the outer builder,
meaning the full tile rebuild including two `_tileDecoration()` calls fires on every controller
tick.

**Call chain:**
```
AnimatedBuilder(Listenable.merge([merge, spawn, glow]))
  → builder() → Transform.scale() → _buildTile(tileSize)
    → AnimatedBuilder(_glowController)
      → Container(decoration: _tileDecoration().copyWith(...))
```

During a merge animation (400ms), all 3 controllers may be ticking simultaneously for
recently-merged tiles. At 60fps this is up to 24 redundant full tile rebuilds per animation.

**Measured severity:** PENDING — expected P3 (<1% frames over 16ms in isolation). Likely
masked by JS-01 jank during profiling. Fix only if profiling after JS-01 resolution shows
residual jank.

**Recommended fix (Phase 2):** Monitor after JS-01/JS-02 fixes. If residual jank remains,
consolidate to a single `AnimationController` driving all animations via `TweenSequence`
or decouple the outer builder to only listen to `_mergeController` and `_spawnController`,
with `_glowController` handled separately inside `_buildTile()`.

---

## SoundService Audit (PERF-05)

**Status:** RESOLVED — N/A

**Finding:** `lib/core/services/sound_service.dart` is a haptic-only placeholder.

Code confirmation:
```dart
// sound_service.dart
void play(GameSound sound) {
  if (!isSoundEnabled) return;
  // Sound playback will be implemented when audio assets are added.
  // Placeholder: trigger haptic as audio substitute.
  HapticService.instance.light();
}
```

No `AudioPlayer` instances exist anywhere in `SoundService` or `HapticService`. The
`audioplayers` package is declared in `pubspec.yaml` but not imported in `sound_service.dart`.
The service class delegates exclusively to `HapticFeedback` from the Flutter SDK.

**Consequence:** There is no AudioPlayer lifecycle to manage, no player pool risk, no
memory leak from unreleased audio resources.

**Action:** None required for this milestone. If real audio playback is added in a future
milestone, re-audit for AudioPlayer lifecycle management (create/dispose pairing, pool
sizing relative to concurrent sounds, background audio behavior on iOS vs Android).

**PERF-05 status:** Closed — resolved N/A.

---

## Recommended Phase 2 Fix Priority

Ranked by expected impact based on call-count analysis. Severity column will be updated
with measured data after physical device profiling.

| Priority | ID | Fix | Requirement | Expected Severity | Measured Severity |
|----------|-----|-----|-------------|-------------------|-------------------|
| 1 | JS-01 | TileThemes reactive refactor — eliminate per-frame Hive read + regex | PERF-02 | P1 | PENDING |
| 2 | JS-02 | RepaintBoundary isolation — decouple game board from score/HUD repaints | PERF-03 | P2 | PENDING |
| 3 | — | BLoC `buildWhen` guards — prevent unnecessary widget rebuilds on unrelated state changes | PERF-04 | P2–P3 | PENDING |
| 4 | JS-03 | AnimationController consolidation — reduce redundant tile rebuilds during animation | — | P3 | PENDING |

### Fix Dependencies

- JS-01 fix (PERF-02) must land before measuring JS-02 and JS-03 — TileThemes jank likely
  masks the repaint and animation issues in profiler flame charts.
- BLoC `buildWhen` guards (PERF-04) should be added as part of the JS-01 refactor since
  the reactive theme will flow through BLoC state.

---

## Phase 2 Handoff Notes

### What Phase 2 Needs to Know

1. **TileThemes is the primary target.** The 4,800+ regex ops/second pattern is certain
   to show up in the flame chart. Address this before profiling any other concern.

2. **Double decoration call is a quick win within JS-01.** The `_tileDecoration(tileSize).copyWith(...)`
   pattern in `_buildTile()` creates the full BoxDecoration twice. This can be fixed by
   caching the result in a local variable before the copyWith call — independent of the
   broader TileThemes reactive refactor.

3. **No RepaintBoundary exists.** Phase 2 starts from zero isolation. The recommended
   structure is:
   ```
   GamePage
   ├── RepaintBoundary  ← isolates HUD/score
   │   └── [score, combo, controls]
   └── RepaintBoundary  ← isolates game board
       └── [BoardWidget → 16x TileWidget]
   ```

4. **SoundService requires no Phase 2 work.** PERF-05 is fully closed.

5. **Dev tools from Phase 1 are available.** The PerformanceOverlay toggle and regression
   check button in Dev Options can be used to validate Phase 2 fixes without needing
   Flutter DevTools each time.

---

## Raw Observations

*To be filled in after physical device profiling session.*

Key questions for the profiling session:
- Does the flame chart show `TileThemes._activeTheme` / `_extractThemeId` in UI thread work?
- What fraction of frame time is GPU vs UI thread?
- Do frames spike primarily on swipe events (tile movement) or during idle animation (glow pulse)?
- Does "Highlight Repaints" confirm score + HUD repaint on every swipe?
- Does the regression check pass or fail at baseline (before any Phase 2 fixes)?

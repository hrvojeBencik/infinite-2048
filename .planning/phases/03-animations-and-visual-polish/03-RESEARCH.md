# Phase 3: Animations and Visual Polish - Research

**Researched:** 2026-03-26
**Domain:** Flutter animation APIs, go_router transitions, haptic feedback, confetti, native splash
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Merge Animation (ANIM-01)**
- D-01: Keep the existing TileWidget scale-pop animation (400ms, 0.85→1.18→0.95→1.0, easeOutCubic). Do not change the curve or timing.
- D-02: Add swipe input blocking during the merge animation. Swipes must not register while the animation is playing. This is the key fix — the animation already exists but swipes can fire mid-animation.

**Screen Transitions (ANIM-02)**
- D-03: Lateral navigation keeps the existing fade + slight slide-right (300ms, `_buildTransitionPage()`). No changes needed.
- D-04: Full-screen modals (level complete dialog, game over dialog) switch to slide-up from bottom transition. Currently using `showDialog()` default — replace with custom slide-up.

**Haptic Feedback on Merge (ANIM-03)**
- D-05: Haptic feedback fires on tile merge events via `sl<HapticService>()`. HapticService is already extracted and in DI from Phase 2. Wire merge haptic in the GameBloc listener or the TileWidget merge animation trigger.

**Confetti Celebration (ANIM-04)**
- D-06: Add the `confetti` package to pubspec.yaml.
- D-07: Confetti burst fires from the top of the screen when the level complete dialog appears. 2-3 second duration, then fades. Fires only on level complete — not on achievements or other events.

**XP Bar Animation (ANIM-05)**
- D-08: XP bar animates smoothly on XP gain. Claude has discretion on implementation approach (AnimatedContainer, TweenAnimationBuilder, or custom AnimationController).

**Particle Effects (ANIM-06)**
- D-09: ParticleEffect widget already exists. Claude has discretion on polishing — ensure consistent visual style with the rest of the animations. No major rework.

**Native Splash Screen (ANIM-07)**
- D-10: Add `flutter_native_splash` package to pubspec.yaml (dev dependency).
- D-11: Splash screen shows the app icon centered on the app's dark background color (`AppColors.background` = `0xFF0A0E21`). No gradient. Matches the app's dark theme for seamless transition to home screen.

### Claude's Discretion
- XP bar animation approach (ANIM-05)
- Particle effect polish details (ANIM-06)
- Exact confetti configuration (particle count, colors, blast direction)
- Whether to use `ConfettiController` inline or extract to a reusable widget
- Haptic feedback timing relative to animation
- Swipe blocking implementation (AnimationController status check vs. flag in GameBloc)

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| ANIM-01 | Tile merge produces satisfying pop/scale animation with easing | Animation already exists. Fix: block swipes using `_mergeController.isAnimating` guard in `_handleSwipe`. |
| ANIM-02 | Screen transitions use consistent fade (lateral) and slide-up (modal) patterns | Lateral transitions already correct. Fix: replace `showDialog()` for level-complete/game-over with `showGeneralDialog()` + custom `pageBuilder` using slide-up `SlideTransition`. |
| ANIM-03 | Haptic feedback fires on tile merge events | `HapticService.merge()` already implemented. Fix: call it from `_triggerJuiceEffects()` whenever `lastMergeCount > 0` (already wired — confirm it actually fires on plain merges vs only combos/bombs). |
| ANIM-04 | Confetti animation plays on level completion | Custom `_ConfettiPainter` already in `LevelCompleteDialog`. The `confetti` package (D-06) adds a richer burst from top-of-screen. Integrate `ConfettiController` at dialog entry point (`_showLevelComplete` in game_page.dart). |
| ANIM-05 | XP bar animates smoothly on XP gain | Current `XpBar` widget is fully static (no animation). Convert fill bar to use `TweenAnimationBuilder<double>` for smooth width transition. |
| ANIM-06 | Particle effects polished with consistent visual style | `ParticleEffect.explode()` uses warm orange/red palette. Polish: align palette closer to AppColors (primary purple, secondary gold) for brand consistency. No structural rework. |
| ANIM-07 | Native splash screen displays during app startup | Use `flutter_native_splash` 2.4.7. Config via `pubspec.yaml` section. Run `dart run flutter_native_splash:create` to generate. Background: `#0A0E21`. Icon: existing `assets/icon/icon.png`. |
</phase_requirements>

---

## Summary

Phase 3 is a surgical polish phase on top of a solid animation foundation from Phase 2. The core merge animation (TileWidget), the particle system (ParticleEffect), and the haptic infrastructure (HapticService) are all functional — the work is integration, wiring, and one missing animation (XP bar).

The most architecturally interesting task is swipe blocking (ANIM-01). The `GestureDetector.onPanEnd` in `game_page.dart` must check whether any tile is currently mid-merge before dispatching `SwipeMade`. The safest approach is checking `AnimationController.isAnimating` status exposed from the game board, or adding a `_animating` flag to `GameBloc` state that tiles signal when a merge begins. The flag-in-bloc approach is safer for the RepaintBoundary isolation already in place.

The modal transition change (ANIM-02) requires replacing `showDialog()` calls in `_showLevelComplete` and `_showGameOver` with `showGeneralDialog()`, which accepts a full custom `transitionBuilder` for slide-up behavior. The existing dialog widget code (LevelCompleteDialog, GameOverDialog) needs no changes — only the call site in game_page.dart changes.

The confetti package (ANIM-04) adds a full-screen `ConfettiWidget` overlaid on the dialog. Because `LevelCompleteDialog` already has a custom `_ConfettiPainter`, the cleanest integration is to add the `confetti` package's `ConfettiWidget` as a sibling in the dialog's Stack, positioned at `Alignment.topCenter`. The existing custom painter can remain for the fallback/in-dialog particles.

**Primary recommendation:** Execute in dependency order: ANIM-07 (splash — zero runtime risk), ANIM-03 (verify haptic wiring), ANIM-01 (swipe blocking), ANIM-02 (dialog transitions), ANIM-04 (confetti), ANIM-05 (XP bar), ANIM-06 (particle palette).

---

## Standard Stack

### Core (already in project)
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_animate | ^4.5.2 | Chainable animation DSL | Already used in LevelCompleteDialog and GameOverDialog for fadeIn/slideY/shake |
| flutter_bloc | ^9.1.1 | State management | Project-wide BLoC pattern |
| go_router | ^17.1.0 | Navigation | Project router, CustomTransitionPage pattern established |

### New Dependencies
| Library | Version | Purpose | Notes |
|---------|---------|---------|-------|
| confetti | ^0.8.0 | Rich confetti particle burst widget | pub.dev latest as of 2026-03-26; published 2024-09-28 |
| flutter_native_splash | ^2.4.7 | Generates native splash screens for iOS and Android | dev_dependency; published 2025-10-17 |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| confetti package | Custom _ConfettiPainter (already exists) | Custom painter is already built but is scoped inside LevelCompleteDialog only; `confetti` package provides full-screen top-blast out of the box, matching D-07 |
| flutter_native_splash | flutter_splash_screen, Manual Xcode/gradle | flutter_native_splash is the ecosystem standard; manual setup is error-prone for both platforms simultaneously |
| TweenAnimationBuilder (XP bar) | AnimatedContainer, explicit AnimationController | TweenAnimationBuilder is the lightest-weight approach for a single value transition; no controller lifecycle to manage |

**Installation:**
```bash
# Add to pubspec.yaml dependencies:
#   confetti: ^0.8.0
# Add to pubspec.yaml dev_dependencies:
#   flutter_native_splash: ^2.4.7
flutter pub get
dart run flutter_native_splash:create
```

---

## Architecture Patterns

### Recommended Project Structure
No new directories needed. All changes are modifications to existing files plus one pubspec.yaml addition.

```
lib/
  features/game/presentation/
    pages/game_page.dart          # ANIM-01 swipe blocking, ANIM-02 showGeneralDialog, ANIM-04 confetti overlay
    widgets/
      tile_widget.dart            # ANIM-01: expose _mergeController status (or signal bloc)
      level_complete_dialog.dart  # ANIM-04: ConfettiWidget integration
      game_over_dialog.dart       # ANIM-02: no widget changes (transition is in call site)
      particle_effects.dart       # ANIM-06: palette polish
  features/progression/presentation/
    widgets/xp_bar.dart           # ANIM-05: TweenAnimationBuilder fill bar
assets/
  icon/icon.png                   # Already exists — used by flutter_native_splash
pubspec.yaml                      # Add confetti + flutter_native_splash
flutter_native_splash.yaml        # New config file (or inline in pubspec.yaml)
```

### Pattern 1: Swipe Blocking via GameBloc State Flag (ANIM-01)
**What:** Add a `bool isAnimating` field to `GamePlaying` state. TileWidget signals merge start/end to GameBloc. GestureDetector reads the flag before dispatching.
**When to use:** Preferred over reading AnimationController status from child widget — keeps input logic in the BLoC layer, consistent with Phase 2's RepaintBoundary isolation.

**Alternative — Direct AnimationController check:** Simpler if a top-level `bool _boardAnimating` local variable in `_GamePageState` is updated when juice effects fire. Given juice effects already fire via `_triggerJuiceEffects`, a local `_boardAnimating` flag is the minimal-change approach.

**Recommended minimal approach:**
```dart
// In _GamePageState:
bool _boardAnimating = false;

void _triggerJuiceEffects(GamePlaying state) {
  if (state.lastMergeCount > 0 || state.hadBombExplosion) {
    setState(() => _boardAnimating = true);
    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) setState(() => _boardAnimating = false);
    });
  }
  // ... rest of existing juice effects
}

// In onPanEnd handler:
if (_boardAnimating) return;  // block swipe during animation
```

This is the least-invasive approach: no BLoC changes, no widget-to-parent signaling, 420ms matches the 400ms merge animation with 20ms buffer.

### Pattern 2: Slide-Up Modal Transition (ANIM-02)
**What:** Replace `showDialog()` with `showGeneralDialog()` + slide-up `transitionBuilder`.
**When to use:** For all full-screen modals that appear from game events (level complete, game over).

```dart
// Source: Flutter official docs — showGeneralDialog
void _showLevelComplete(BuildContext context, GameWon state) {
  sl<AdService>().onLevelCompleted();
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) {
      return LevelCompleteDialog(/* same args as before */);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}
```

Apply the same pattern to `_showGameOver`.

### Pattern 3: ConfettiWidget Integration (ANIM-04)
**What:** Add `ConfettiWidget` from the `confetti` package overlaid at the top of the screen when level complete dialog appears.
**When to use:** On `GameWon` state in BlocListener. Fire once, auto-stop after 3 seconds.

The cleanest integration is to add the ConfettiController and ConfettiWidget directly inside `LevelCompleteDialog` (which is already a StatefulWidget with its own animation controllers), positioned at `Alignment.topCenter` in the existing Stack.

```dart
// Source: confetti package README (pub.dev/packages/confetti)
import 'package:confetti/confetti.dart';

// In _LevelCompleteDialogState.initState():
_confettiController = ConfettiController(
  duration: const Duration(seconds: 3),
);

// In initState Future.delayed:
_confettiController.play();  // fires at dialog open

// In the Stack, first child (above confetti painter):
Align(
  alignment: Alignment.topCenter,
  child: ConfettiWidget(
    confettiController: _confettiController,
    blastDirectionality: BlastDirectionality.explosive,
    numberOfParticles: 25,
    gravity: 0.2,
    colors: const [
      AppColors.secondary,    // gold
      AppColors.primary,      // purple
      AppColors.success,      // green
      Color(0xFFFF6B6B),      // coral
      Color(0xFF48DBFB),      // cyan
    ],
    shouldLoop: false,
  ),
),
```

Note: The existing `_confettiController` in LevelCompleteDialog is an `AnimationController` (custom painter). Rename it to `_particleController` or use a different variable name to avoid collision with the `confetti` package's `ConfettiController`.

### Pattern 4: XP Bar Animation (ANIM-05)
**What:** Replace static `SizedBox(width: progressWidth)` with `TweenAnimationBuilder<double>`.
**When to use:** When a StatelessWidget receives a changing value and needs to animate between values without lifecycle complexity.

```dart
// In XpBar.build(), replace the LayoutBuilder inner logic:
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
  duration: const Duration(milliseconds: 600),
  curve: Curves.easeOutCubic,
  builder: (context, animatedProgress, _) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final progressWidth = constraints.maxWidth * animatedProgress;
        return Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.background.withAlpha(150),
              ),
            ),
            SizedBox(
              width: progressWidth,
              height: 10,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  },
),
```

Note: `TweenAnimationBuilder` animates from `begin` to `end` when `end` changes. For a StatelessWidget that receives new `profile` values, the tween `begin` must reflect the previous value. A simpler alternative: convert `XpBar` to a `StatefulWidget` and use an `AnimationController`, which gives precise control over the `begin` value across rebuilds. Given the `XpBar` receives the full `PlayerProfile` and lives in the home/progression screen (not the game page), the `StatefulWidget` + explicit controller approach is recommended for correctness.

### Pattern 5: Native Splash Screen (ANIM-07)
**What:** Configure `flutter_native_splash` to generate platform-specific splash files.
**When to use:** Once at setup; re-run after icon changes.

```yaml
# Add to pubspec.yaml (top-level section, NOT under flutter:)
flutter_native_splash:
  color: "#0A0E21"
  image: assets/icon/icon.png
  android_12:
    color: "#0A0E21"
    image: assets/icon/icon.png
  web: false
```

```bash
dart run flutter_native_splash:create
```

This modifies `android/app/src/main/res/` (adds splash drawables) and `ios/Runner/Base.lproj/LaunchScreen.storyboard` + `Assets.xcassets`. These generated files must be committed to git.

**Critical:** `flutter_native_splash` is a dev dependency used only at generation time. It is NOT a runtime import and adds zero runtime binary size.

### Anti-Patterns to Avoid

- **Do NOT add `ConfettiWidget` in game_page.dart as a Stack overlay:** The dialog already has its own Stack and StatefulWidget with controllers. Keeping confetti inside the dialog widget keeps lifecycle management clean and avoids needing a GlobalKey to control it from the page level.
- **Do NOT use `AnimatedContainer` for XP bar:** `AnimatedContainer` reacts to build-time property changes but does not animate from previous values across `didUpdateWidget` changes predictably — `TweenAnimationBuilder` or `AnimationController` are the correct patterns.
- **Do NOT block swipes at the GameBloc level (add event filtering to reducer):** Input blocking belongs in the UI layer (`onPanEnd`), not in the BLoC. The BLoC should remain unaware of animation state.
- **Do NOT modify `_buildTransitionPage()` for modal dialogs:** That helper is for route transitions only. Dialog transitions use `showGeneralDialog` at the call site.
- **Do NOT use `showDialog` with `useSafeArea: false` as a workaround for slide-up:** `showGeneralDialog` with a custom `transitionBuilder` is the correct Flutter pattern for non-default dialog transitions.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Full-screen confetti burst | Custom CustomPainter in page-level Stack | `confetti` package (ConfettiWidget + ConfettiController) | Handles particle physics, blast direction, gravity, color variance, loop control. The existing custom painter in LevelCompleteDialog is in-dialog only. |
| Native splash screen generation | Manual Xcode storyboard + Android drawable XML editing | `flutter_native_splash` | Platform-specific XML/storyboard details differ between Android 11, Android 12+ (splash API), and iOS. The package handles all three correctly. |
| Custom easing animation DSL | Manual AnimationController + Tween chains for every animation | `flutter_animate` (already installed) | The project already uses it. For simple sequential widget animations, `.animate().fadeIn().slideY()` is cleaner than manual controllers. |

**Key insight:** In game animation, the hardest bugs come from animation lifecycle management. Prefer the existing controllers (TileWidget has 3 already) and add minimal new controllers only where required (ConfettiController in LevelCompleteDialog). Every new AnimationController needs a `dispose()` — this is a common memory leak source.

---

## Common Pitfalls

### Pitfall 1: Variable Name Collision (ConfettiController vs AnimationController)
**What goes wrong:** `LevelCompleteDialog` already has a field named `_confettiController` typed as `AnimationController`. Adding `confetti` package's `ConfettiController` with the same variable name causes a type error.
**Why it happens:** The existing custom confetti particle system re-used the "confetti" naming convention before the package was added.
**How to avoid:** Rename the existing `AnimationController _confettiController` to `_particleController` (and update all references in the file) before adding `ConfettiController _confettiController` from the package.
**Warning signs:** Dart analyzer shows type mismatch on `_confettiController.forward()` vs `_confettiController.play()`.

### Pitfall 2: Swipe Blocking Duration Mismatch
**What goes wrong:** Swipe blocking timer is shorter than the animation, allowing mid-animation swipes. Or it is too long, making the game feel sluggish.
**Why it happens:** The merge animation is 400ms but tile position animations or spawn animations may add perceived delay. Using a hardcoded delay that doesn't match the actual animation chain.
**How to avoid:** The `_mergeController` duration is exactly 400ms. Use 420ms as the block duration (20ms buffer). Do NOT block for the full spawn animation (350ms) — only block for the merge duration since swipe → merge → spawn is sequential.
**Warning signs:** Players can queue moves and get double-moves, or the board feels "sticky" between swipes.

### Pitfall 3: `showGeneralDialog` Missing `RouteSettings`
**What goes wrong:** Analytics observer or route tracking breaks because `showGeneralDialog` dialogs don't have named routes by default.
**Why it happens:** `showDialog` wraps content in a `DialogRoute` with analytics metadata. `showGeneralDialog` creates a raw `RawDialogRoute`.
**How to avoid:** Pass `routeSettings: const RouteSettings(name: '/level-complete')` to `showGeneralDialog`. Check whether `AnalyticsService.observer` tracks dialog routes — if it does, this is important.
**Warning signs:** Analytics events for level-complete screens stop appearing in Firebase Analytics dashboard.

### Pitfall 4: flutter_native_splash Storyboard Conflict (iOS)
**What goes wrong:** iOS build fails with "Multiple commands produce LaunchScreen.storyboard" or the splash screen shows the wrong color on first run.
**Why it happens:** `flutter_launcher_icons` (already a dev dependency) and `flutter_native_splash` both touch iOS launch assets. Running them in the wrong order or with conflicting config leaves stale artifacts.
**How to avoid:** Run `dart run flutter_native_splash:create` AFTER `dart run flutter_launcher_icons:main`. Do NOT use `flutter_native_splash` with `fullscreen: true` on iOS without testing — it can produce a white flash before the storyboard renders.
**Warning signs:** After clean build, iOS simulator shows brief white flash before the dark splash.

### Pitfall 5: TweenAnimationBuilder Animating from Wrong Start Value
**What goes wrong:** XP bar animates from 0 (or the wrong progress value) on every rebuild, not from the previous XP value.
**Why it happens:** `TweenAnimationBuilder`'s `tween.begin` is fixed at construction. When the widget rebuilds with a new `end` value, it animates from the `begin` in the tween, not from the current animated position.
**How to avoid:** Use a `StatefulWidget` with an explicit `AnimationController`. Store `_previousProgress` in state, update it in `didUpdateWidget`, and drive the animation from there. This is the correct approach for values that update multiple times over widget lifetime.
**Warning signs:** Every time the player gains XP, the bar flashes back to empty before filling again.

### Pitfall 6: RepaintBoundary Invalidation from Dialog Overlay
**What goes wrong:** Confetti animation in `LevelCompleteDialog` causes the game board (behind the dialog barrier) to repaint on every frame.
**Why it happens:** Material dialog barriers are overlaid on the Navigator, which is above the game page in the widget tree. The game page's RepaintBoundary zones should be unaffected by dialog content above them.
**How to avoid:** This should NOT be a problem by Flutter's design — dialogs are pushed to a separate route above the game page Scaffold. Verify with Flutter DevTools "Highlight Repaints" during animation. If unexpected repaints occur, ensure the confetti widget is clipped to the dialog bounds.
**Warning signs:** Frame rate drops during confetti despite the game board being invisible behind the dialog.

---

## Code Examples

Verified patterns from official sources and existing codebase:

### Swipe Blocking (Local Flag Pattern)
```dart
// In _GamePageState — minimal change, no BLoC modification
bool _boardAnimating = false;

void _triggerJuiceEffects(GamePlaying state) {
  // Block swipes for the merge animation duration
  if (state.lastMergeCount > 0 || state.hadBombExplosion) {
    setState(() => _boardAnimating = true);
    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) setState(() => _boardAnimating = false);
    });
  }
  // ... existing juice effect code unchanged ...
}

// In GestureDetector.onPanEnd, add check at top:
onPanEnd: (details) {
  final gameBlocState = context.read<GameBloc>().state;
  final isPaused = gameBlocState is GamePlaying &&
      gameBlocState.session.status == GameStatus.paused;
  if (isPaused || _boardAnimating) return;  // <-- add _boardAnimating check
  // ... existing direction dispatch unchanged ...
},
```

### Slide-Up Modal (showGeneralDialog)
```dart
// Replaces showDialog call in _showLevelComplete and _showGameOver
// Source: Flutter docs — showGeneralDialog
showGeneralDialog(
  context: context,
  barrierDismissible: false,
  barrierColor: Colors.black54,
  barrierLabel: 'Level Complete',
  transitionDuration: const Duration(milliseconds: 350),
  routeSettings: const RouteSettings(name: '/level-complete'),
  pageBuilder: (context, animation, secondaryAnimation) {
    return LevelCompleteDialog(/* unchanged args */);
  },
  transitionBuilder: (context, animation, secondaryAnimation, child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  },
);
```

### ConfettiController Lifecycle
```dart
// Source: pub.dev/packages/confetti
// In _LevelCompleteDialogState:
late ConfettiController _confettiController;

@override
void initState() {
  super.initState();
  _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );
  // Fire after 200ms delay (existing pattern in the widget)
  Future.delayed(200.ms, () {
    if (mounted) _confettiController.play();
  });
}

@override
void dispose() {
  _confettiController.dispose();
  // ... other dispose calls ...
  super.dispose();
}
```

### flutter_native_splash Config
```yaml
# In pubspec.yaml, top-level (same level as 'flutter:', 'dependencies:')
flutter_native_splash:
  color: "#0A0E21"
  image: assets/icon/icon.png
  android_12:
    color: "#0A0E21"
    image: assets/icon/icon.png
  web: false
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Manual storyboard editing for iOS splash | flutter_native_splash package | 2019+ | Handles Android 12 splash API (SplashScreen) and iOS simultaneously |
| showDialog for all modals | showGeneralDialog for custom-transition modals | Flutter 1.x → 2.x | showDialog wraps in DialogRoute; showGeneralDialog gives full transitionBuilder control |
| Tween.animate() for simple one-value animations | TweenAnimationBuilder | Flutter 1.7+ | Stateless, no controller lifecycle to manage for single-value transitions |

**Deprecated/outdated:**
- `ConfettiWidget.blastDirection` (single direction): The current `confetti` 0.8.0 API uses `blastDirectionality: BlastDirectionality.explosive` for omnidirectional or `BlastDirectionality.directional` + `blastDirection` for single-direction. Confirm API from pub.dev docs before coding.

---

## Open Questions

1. **Haptic already wired for plain merges?**
   - What we know: `_triggerJuiceEffects()` calls `sl<HapticService>().merge()` when `state.lastMergeCount > 0` (line 139-141 of game_page.dart)
   - What's unclear: Whether `lastMergeCount > 0` is set correctly for all merge types in GameBloc, or only for multi-merges. ANIM-03 may already be complete.
   - Recommendation: Verify with a physical device test. If haptic fires on single tile merge, ANIM-03 is done. If not, check how `lastMergeCount` is set in GameBloc's SwipeMade handler.

2. **Where is XpBar rendered?**
   - What we know: XpBar widget is at `lib/features/progression/presentation/widgets/xp_bar.dart` and takes a `PlayerProfile`. Its usage location is not yet confirmed (likely home page or profile page, not game page).
   - What's unclear: Where exactly the widget is used in the widget tree — determines whether animation needs to handle rebuild across navigation.
   - Recommendation: Grep for `XpBar(` usages before implementing animation to confirm the render context.

3. **confetti package Android 12 compatibility**
   - What we know: Package version 0.8.0, published 2024-09-28. Listed as working on Flutter stable.
   - What's unclear: Whether there are known issues with `confetti` on Android 12+ regarding window insets or overlay rendering.
   - Recommendation: Test on Android 12 emulator (API 31) as part of ANIM-04 verification. The confetti widget renders in a Stack inside the dialog, which is well above the system chrome layer — should be safe.

---

## Environment Availability

Step 2.6: SKIPPED — Phase is purely Flutter code and package additions. No external services, databases, or CLI tools beyond Flutter SDK (already verified working in Phases 1 and 2). The `dart run flutter_native_splash:create` command uses the existing Dart SDK — no additional install needed.

---

## Validation Architecture

Step 2.4: SKIPPED — `workflow.nyquist_validation` is explicitly set to `false` in `.planning/config.json`.

---

## Sources

### Primary (HIGH confidence)
- Direct codebase inspection: `tile_widget.dart`, `game_page.dart`, `level_complete_dialog.dart`, `game_over_dialog.dart`, `particle_effects.dart`, `score_display.dart`, `xp_bar.dart`, `haptic_service.dart`, `router.dart` — all read in full
- `pubspec.yaml` — confirmed existing dependencies and versions
- `app_colors.dart` — confirmed `AppColors.background = Color(0xFF0A0E21)` for splash config

### Secondary (MEDIUM confidence)
- pub.dev API: confetti 0.8.0 (published 2024-09-28), flutter_native_splash 2.4.7 (published 2025-10-17) — verified via API call
- Flutter official docs patterns: `showGeneralDialog`, `TweenAnimationBuilder`, `CustomTransitionPage` — standard Flutter APIs verified against training knowledge (stable since Flutter 2.x)

### Tertiary (LOW confidence)
- confetti package API details (ConfettiController.play(), BlastDirectionality enum) — from training data + pub.dev README; should be verified against package source before coding

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — packages confirmed on pub.dev API, versions verified
- Architecture: HIGH — based on full codebase read; patterns are standard Flutter APIs
- Pitfalls: HIGH — derived from direct code analysis (variable name collision, flag timing)
- XP bar implementation: MEDIUM — widget location/usage not fully confirmed (open question 2)

**Research date:** 2026-03-26
**Valid until:** 2026-05-26 (stable domain — Flutter animation APIs change slowly)

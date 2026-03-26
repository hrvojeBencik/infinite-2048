---
phase: 03-animations-and-visual-polish
plan: 01
subsystem: visual-polish
tags: [splash-screen, animation, particles, xp-bar, dependencies]
dependency_graph:
  requires: []
  provides: [confetti-package, native-splash, animated-xp-bar, brand-particle-palette]
  affects: [progression-xp-bar, game-particle-effects, android-splash, ios-splash]
tech_stack:
  added: [confetti ^0.8.0, flutter_native_splash ^2.4.7]
  patterns: [AnimationController+Tween, didUpdateWidget animation, flutter_native_splash codegen]
key_files:
  created: []
  modified:
    - pubspec.yaml
    - pubspec.lock
    - lib/features/progression/presentation/widgets/xp_bar.dart
    - lib/features/game/presentation/widgets/particle_effects.dart
    - android/app/src/main/res/drawable/launch_background.xml
    - android/app/src/main/res/values-v31/styles.xml
    - android/app/src/main/res/values-night-v31/styles.xml
    - ios/Runner/Assets.xcassets/LaunchImage.imageset/
    - ios/Runner/Assets.xcassets/LaunchBackground.imageset/
    - ios/Runner/Base.lproj/LaunchScreen.storyboard
    - ios/Runner/Info.plist
decisions:
  - "confetti ^0.8.0 added as runtime dep (not dev) because Plan 02 uses it at runtime for the merge celebration widget"
  - "XpBar uses explicit AnimationController + Tween instead of AnimatedContainer to avoid flash-to-zero on rebuild (per Research Pitfall 5)"
  - "Particle palette uses Color() literals instead of AppColors references to keep the list static const"
metrics:
  duration_seconds: 160
  completed_date: "2026-03-26"
  tasks_completed: 3
  files_modified: 14
---

# Phase 03 Plan 01: Dependencies, Splash Screen, XP Bar Animation, Particle Palette Summary

**One-liner:** Dark native splash screen generated, XP bar animated with 600ms easeOutCubic tween, particle palette replaced with brand purple/gold/coral/cyan colors, and confetti package added for Plan 02.

## What Was Built

### Task 1: Dependencies and Native Splash Screen (ANIM-07)
- Added `confetti: ^0.8.0` to runtime dependencies (used in Plan 02 for merge celebration)
- Added `flutter_native_splash: ^2.4.7` to dev_dependencies
- Added `flutter_native_splash:` config block in pubspec.yaml with `color: "#0A0E21"` and `image: assets/icon/icon.png`
- Ran `dart run flutter_native_splash:create` which generated:
  - Android: density-specific splash PNGs (hdpi/mdpi/xhdpi/xxhdpi/xxxhdpi), launch_background.xml updates, Android 12 styles (values-v31, values-night-v31)
  - iOS: LaunchImage.imageset updated, LaunchBackground.imageset created, LaunchScreen.storyboard updated, Info.plist updated
- App now cold-starts into a dark (#0A0E21) native splash with centered icon instead of white flash

### Task 2: Animated XP Bar (ANIM-05)
- Converted `XpBar` from `StatelessWidget` to `StatefulWidget` with `_XpBarState`
- Added `SingleTickerProviderStateMixin` with explicit `AnimationController` (600ms duration)
- `initState()` creates initial animation from 0.0 → current progress and calls `_controller.forward()`
- `didUpdateWidget()` creates new `Tween<double>(begin: _previousProgress, end: newProgress)` and calls `_controller.forward(from: 0.0)` — no flash-to-zero on rebuild
- `AnimatedBuilder` wraps the `LayoutBuilder` fill bar; `progressWidth = constraints.maxWidth * _animation.value`
- XP text (`xpForCurrentLevel / xpRequiredForNextLevel`) still shows actual non-animated values
- `dispose()` correctly disposes `_controller`

### Task 3: Brand-Aligned Particle Palette (ANIM-06)
- Replaced warm orange/red `_particleColors` list in `ParticleEffectState` with brand-consistent colors:
  - `0xFF6C63FF` — AppColors.primary (purple)
  - `0xFF8B83FF` — AppColors.primaryLight
  - `0xFFFFD700` — AppColors.secondary (gold, retained)
  - `0xFFFF6B6B` — coral (from confetti palette)
  - `0xFF48DBFB` — cyan (from confetti palette)
  - `0xFFFFAB40` — amber accent (warm contrast, retained)
  - `0xFFFFFFFF` — white spark
- No structural changes to `explode()`, particle physics, painter, or glow effects per D-09

## Verification

- `flutter pub get`: succeeded, 8 new packages resolved
- `dart run flutter_native_splash:create`: completed with iOS and Android assets generated
- `flutter analyze xp_bar.dart`: No issues found
- `flutter analyze particle_effects.dart`: No issues found

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None — all three changes are complete with no placeholder data.

## Commits

| Task | Commit | Message |
|------|--------|---------|
| 1 | 4f17ed5 | feat(03-01): add confetti + flutter_native_splash deps, generate dark splash screen |
| 2 | 5cb1ab9 | feat(03-01): animate XP bar fill with 600ms easeOutCubic on XP gain |
| 3 | a339c5c | feat(03-01): replace particle palette with brand-aligned purple/gold/coral/cyan colors |

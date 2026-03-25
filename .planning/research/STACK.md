# Stack Research

**Domain:** Flutter mobile game polish, performance optimization, and app store preparation
**Researched:** 2026-03-25
**Confidence:** HIGH (verified against pub.dev and official Flutter docs)

---

## Context: What's Already Installed

The following packages are ALREADY in pubspec.yaml and do NOT need to be added:

| Package | Version | Relevant for this milestone |
|---------|---------|----------------------------|
| flutter_animate | ^4.5.2 | Primary animation toolkit — use this for all tile/UI animations |
| flutter_launcher_icons | ^0.14.4 | App icon generation — needs configuration, not replacement |
| in_app_review | ^2.0.10 | Store review prompt — already wired |
| flutter_lints | ^6.0.0 | Linting — already active |
| google_fonts | ^8.0.2 | Typography — already available |

---

## New Packages to Add

### Core: Splash Screen

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| flutter_native_splash | ^2.4.7 | Generate native iOS/Android splash screens | Without this, the app shows Flutter's default white flash before the first frame. Eliminates the jarring cold-start experience. Generates platform-native code for iOS (LaunchScreen.storyboard) and Android (including Android 12+ SplashScreen API). Run once at build time via `dart run flutter_native_splash:create`. |

### Supporting: Visual Polish

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| confetti | ^0.8.0 | Particle burst for level completions and high scores | Add to level-complete screen and merge milestone moments. Lightweight, no external assets needed, customizable direction/gravity/color. Use for celebration moments only — not continuous gameplay. |
| share_plus | ^12.0.1 | Share score/achievement cards via native share sheet | Required for "share your score" UX flow. Wraps `ACTION_SEND` (Android) and `UIActivityViewController` (iOS). Enables image sharing from a `RepaintBoundary` capture of the score card. |

### Dev: Screenshot Automation

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| golden_screenshot | ^11.0.1 | Automate App Store and Play Store screenshot generation | Use in `dev_dependencies`. Generates screenshots for all required device sizes (6.5" iPhone, 5.5" iPhone, iPad, etc.) via Flutter golden tests. Eliminates manual screenshot capture across 6+ device sizes. Run `flutter test --update-goldens`. |

---

## Recommended Stack (Complete View)

### Animations — Use What's Already There

`flutter_animate` (^4.5.2) covers 100% of the animation needs for this milestone:

- **Tile merge pop**: `.scale(begin: 1.2, end: 1.0, duration: 150ms, curve: Curves.easeOut)` after a merge event
- **Screen transitions**: `.fadeIn()` and `.slideY()` on page entry via GoRouter
- **Micro-interactions**: `.shake()` on invalid move, `.scale()` on button tap
- **Score increment**: `.custom()` builder for animated number counters

Do NOT add Rive or Lottie for this milestone. They require external asset files, designer tooling, and non-trivial integration. flutter_animate handles code-driven animations with no external assets and is already installed.

### Performance Profiling — Tooling Only (No New Packages)

Flutter DevTools (bundled with Flutter SDK) covers all profiling needs:

- **Jank detection**: Profile mode + Performance view → Frame timeline → flag red frames (>16ms)
- **Memory leaks**: Memory tab → identify allocation spikes, watch for widget rebuild storms
- **Widget rebuilds**: Widget rebuild stats in DevTools Inspector
- **Raster thread**: GPU profiling via Perfetto integration in DevTools

Run with: `flutter run --profile` on a physical device. Simulators/emulators are NOT valid for performance profiling.

Key patterns to audit in this codebase:
1. `GameBloc` — verify state emissions don't trigger full board rebuilds
2. Tile widgets — verify they use `const` constructors where possible
3. `RepaintBoundary` — wrap the game board to isolate repaints from UI chrome

### App Icons — Extend Existing Config

`flutter_launcher_icons` (^0.14.4) is already installed. It needs to be fully configured:

```yaml
flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  remove_alpha_ios: true          # Required — App Store rejects icons with alpha channel
  image_path: "assets/icon/icon.png"
  adaptive_icon_background: "#1A1A2E"   # Match your game's dark background
  adaptive_icon_foreground: "assets/icon/icon_foreground.png"
  adaptive_icon_monochrome: "assets/icon/icon_foreground.png"  # Android 13+ themed icons
  image_path_ios_dark_transparent: "assets/icon/icon_ios_dark.png"   # iOS 18+ dark mode
```

Icon assets needed (create before running):
- `assets/icon/icon.png` — 1024×1024 source (already exists per pubspec assets)
- `assets/icon/icon_foreground.png` — Foreground layer for Android adaptive icon
- `assets/icon/icon_ios_dark.png` — iOS 18+ dark mode variant (optional but recommended)

### Splash Screen Configuration

After adding `flutter_native_splash`, configure in `pubspec.yaml`:

```yaml
flutter_native_splash:
  color: "#1A1A2E"                # Game's dark background — no white flash
  image: assets/icon/icon.png
  color_dark: "#1A1A2E"
  image_dark: assets/icon/icon.png
  fullscreen: true
  android_12:
    color: "#1A1A2E"
    icon_background_color: "#1A1A2E"
    image: assets/icon/icon.png
```

---

## What NOT to Add

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| rive | Requires Rive editor, external .riv asset files, designer involvement. Overkill for tile animations. | flutter_animate (already installed) |
| lottie | Requires After Effects or LottieFiles editor, JSON asset files. 17fps vs Rive's 60fps. Setup cost is high. | flutter_animate (already installed) |
| flutter_screenutil | Adds a global ScreenUtil initialization wrapper that conflicts with existing widget architecture. The 2048 board uses a fixed-size grid that's already responsive via LayoutBuilder. | LayoutBuilder + MediaQuery (already used) |
| Flame engine | The game engine is a pure static class — no game loop, no Flame component tree. Migrating to Flame would be a full rewrite, not polish. | flutter_animate + CustomPainter |
| screenshots (pub.dev package) | Deprecated/unmaintained. Requires a running device + test driver setup. | golden_screenshot (modern, golden-test-based) |
| newton_particles | Heavy physics engine — significant overhead for simple confetti use case | confetti package (lightweight, sufficient) |

---

## Version Compatibility

| Package | Flutter SDK Constraint | Notes |
|---------|----------------------|-------|
| flutter_native_splash 2.4.7 | Flutter 3.x / Dart 3.x | Generates Android 12+ SplashScreen API code. Run `dart run flutter_native_splash:create` |
| confetti 0.8.0 | Flutter 3.x compatible | Published Sept 2024. Null-safe. No known conflicts. |
| share_plus 12.0.1 | Flutter 3.x / Dart 3.x | Requires iOS `NSPhotoLibraryAddUsageDescription` in Info.plist if sharing images |
| golden_screenshot 11.0.1 | Flutter 3.x | Dev dependency only. Use with `flutter test --update-goldens` |

---

## Installation

```bash
# In pubspec.yaml, add to dependencies:
flutter_native_splash: ^2.4.7
confetti: ^0.8.0
share_plus: ^12.0.1

# Add to dev_dependencies:
golden_screenshot: ^11.0.1

# Then:
flutter pub get
dart run flutter_native_splash:create
dart run flutter_launcher_icons
```

---

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| golden_screenshot | Maestro | When you need E2E behavioral tests in addition to screenshots. Maestro is heavier to set up and requires a running device. golden_screenshot is pure Dart/Flutter, runs in CI without a device. |
| confetti | newton_particles | If you need physics-based particle simulations (rain, smoke, explosions) beyond simple confetti. For celebration bursts, confetti is sufficient and lighter. |
| share_plus | Manual platform channels | Never. share_plus is the official Flutter community plugin, well-maintained, and covers both platforms correctly. |
| flutter_native_splash | Manual LaunchScreen.storyboard editing | Only if you need animated splash screen. For static branded splash, flutter_native_splash is correct. |

---

## Stack Patterns by Variant

**For tile merge animation (most important UX moment):**
- Use `flutter_animate` with `.scale(begin: Offset(1.2, 1.2), end: Offset(1.0, 1.0))` + `.then()` chained sequences
- Trigger from `GameBloc` state changes, not from inside tile widget (keeps game engine pure)
- Target 150–200ms duration — fast enough to feel snappy, long enough to be perceivable

**For screen transition polish:**
- Configure GoRouter's `pageBuilder` to use `CustomTransitionPage` with a fade+slide
- Do NOT use Navigator 1.0 transitions — go_router must own all transitions for consistency

**For App Store screenshot generation:**
- Create a dedicated `test/screenshots/` directory
- Write `testGoldens` for each key screen: home, game in progress, level select, achievements, paywall
- Use `GoldenScreenshotDevices.all` to generate all required sizes in one run

**For score sharing (UX flow):**
- Wrap score card widget in `RepaintBoundary` with a `GlobalKey`
- On "Share" tap: capture via `boundary.toImage()` → convert to PNG bytes → `Share.shareXFiles([XFile.fromData(bytes)])`
- This does NOT require the `screenshot` package — use `RepaintBoundary` directly

---

## Sources

- pub.dev/packages/flutter_native_splash — Version 2.4.7 verified, Android 12 configuration confirmed (HIGH confidence)
- pub.dev/packages/confetti — Version 0.8.0 verified (HIGH confidence)
- pub.dev/packages/share_plus — Version 12.0.1 verified (HIGH confidence)
- pub.dev/packages/golden_screenshot — Version 11.0.1 verified (HIGH confidence)
- pub.dev/packages/flutter_animate — Version 4.5.2 confirmed as current stable (HIGH confidence)
- pub.dev/packages/flutter_launcher_icons — Version 0.14.4 confirmed as current (HIGH confidence)
- docs.flutter.dev/perf/ui-performance — DevTools profiling workflow (HIGH confidence)
- docs.flutter.dev/tools/devtools/performance — Profile mode and jank detection (HIGH confidence)
- Rive vs Lottie 2025 comparison (DEV Community) — Rive 60fps vs Lottie 17fps performance (MEDIUM confidence)

---

*Stack research for: Infinite 2048 v1.2 polish, performance, and store preparation*
*Researched: 2026-03-25*

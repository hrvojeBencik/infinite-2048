# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Infinite 2048 ("2048: Merge Quest") is a Flutter mobile game — a 2048 puzzle with level-based progression, zones, special tiles, achievements, endless mode, and premium features. Built for iOS and Android.

## Build & Run Commands

```bash
flutter pub get              # Install dependencies
flutter run                  # Run in debug mode (hot reload: r, restart: R)
flutter run --release        # Run in release mode
flutter analyze              # Lint check
flutter test                 # Run tests (no tests exist yet)
flutter build ios --release  # iOS release build
flutter build appbundle      # Android release build
```

## Architecture

Clean Architecture with feature-based organization using **BLoC** for state management and **GetIt** for dependency injection.

```
lib/
  main.dart          - App entry, initializes Hive, Firebase, DI, ads, analytics
  app/
    app.dart         - Root widget, provides global BLoCs (Auth, Subscription, Achievements)
    di.dart          - GetIt service locator setup (sl), registers all services/repos/blocs
    router.dart      - go_router config, all routes defined here
  core/
    constants/       - GameConstants (board sizes, spawn rates, animation durations),
                       AppConstants (Hive box names, RevenueCat/AdMob IDs)
    theme/           - AppTheme, AppColors, AppTypography, tile visual themes
    services/        - AdService, AnalyticsService, SoundService, RemoteConfigService,
                       MechanicIntroService, RateAppService
    widgets/         - GlassCard, AnimatedButton, PremiumBadge
  features/
    game/            - Core gameplay: GameEngine, Board/Tile entities, GameBloc, GamePage
    endless/         - Endless mode with its own bloc and page
    levels/          - Zone/Level entities, level selection UI, levels loaded from assets/levels/
    achievements/    - Achievement/Challenge entities, daily/weekly challenges
    progression/     - PlayerProfile, XP, streaks, tile themes, level-up
    subscription/    - RevenueCat integration, paywall, premium status
    auth/            - Firebase Auth (Google/Apple sign-in)
    leaderboard/     - Firestore-backed leaderboard (only if Firebase available)
    statistics/      - Local play statistics
    settings/        - Settings page
    onboarding/      - Tutorial overlay
    home/            - Home page (main menu)
    dev/             - Dev options page (debug mode only)
```

## Key Patterns

- **Feature modules** follow `domain/entities`, `domain/repositories`, `data/datasources`, `data/repositories`, `presentation/bloc`, `presentation/pages|widgets`
- **BLoC pattern** with `flutter_bloc` — events and states in separate files under `presentation/bloc/`
- **DI via GetIt** — `sl<T>()` accessor throughout the app. All registrations in `lib/app/di.dart`
- **Local storage** via Hive — box names in `AppConstants`
- **Firebase is optional** — app runs in offline mode if Firebase init fails. Firebase-dependent features (auth, leaderboard, analytics, remote config) are conditionally registered
- **Game engine** (`lib/features/game/domain/engine/game_engine.dart`) is a pure static class with no dependencies — handles board creation, tile spawning, move processing, merging, special tile logic, and bomb explosions
- **Special tile types**: blocker, bomb, wildcard, multiplier, ice — defined in `SpecialTileType` enum, spawn rates configured per level
- **Routes** defined in `lib/app/router.dart` — BLoC providers are created per-route, not globally (except Auth, Subscription, Achievements)
- **Dev routes** (`/dev`, `/dev/game/:levelId`, `/dev/sandbox`) only available in `kDebugMode`

## Tech Stack

- Flutter 3.x / Dart 3.10+
- State: flutter_bloc
- DI: get_it
- Navigation: go_router
- Storage: hive_flutter
- Backend: Firebase (Auth, Firestore, Analytics, Remote Config) — optional
- Ads: google_mobile_ads
- IAP: purchases_flutter (RevenueCat)
- Audio: audioplayers
- Linting: flutter_lints

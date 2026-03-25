# Infinite 2048 ("2048: Merge Quest")

## What This Is

A Flutter mobile game that reimagines the classic 2048 puzzle with level-based progression, zone themes, special tiles (blocker, bomb, wildcard, multiplier, ice), achievements, endless mode, and premium features. Built for iOS and Android with optional Firebase backend for auth, leaderboards, and analytics.

## Core Value

The core 2048 gameplay loop must feel tight, responsive, and satisfying — merging tiles, chasing high scores, and progressing through levels is the ONE thing that must work flawlessly.

## Requirements

### Validated

- ✓ Core 2048 game engine with tile spawning, merging, and move processing — existing
- ✓ Special tile types (blocker, bomb, wildcard, multiplier, ice) with configurable spawn rates — existing
- ✓ Level-based progression with zones loaded from assets — existing
- ✓ Endless mode with dedicated bloc and page — existing
- ✓ Achievement and challenge system (daily/weekly) — existing
- ✓ Player profile with XP, streaks, and tile themes — existing
- ✓ RevenueCat subscription integration with paywall — existing
- ✓ Firebase Auth (Google/Apple sign-in, optional) — existing
- ✓ Firestore-backed leaderboard (conditional on Firebase) — existing
- ✓ AdMob integration — existing
- ✓ Sound service and audio — existing
- ✓ Settings, onboarding tutorial, and home screen — existing
- ✓ Local statistics tracking — existing
- ✓ Remote config service — existing
- ✓ Clean Architecture with BLoC, GetIt DI, go_router navigation — existing
- ✓ Offline-first design (Firebase is optional) — existing
- ✓ Dev tools page (debug mode only) — existing

### Active

## Current Milestone: v1.2 Launch Ready

**Goal:** Polish the entire app experience and prepare store listings for first public release on iOS and Android.

**Target features:**
- Animations & transitions — smooth tile merging, screen transitions, micro-interactions
- Visual design & theme — refine colors, typography, tile visuals, overall aesthetic
- Performance & jank — eliminate frame drops, optimize load times, fix memory issues
- UX flow & usability — improve navigation, onboarding, and confusing screens
- Store preparation — App Store + Google Play listings, screenshots, metadata, icons

### Out of Scope

- New gameplay mechanics — v1.2 is polish only, no new tile types or game modes
- Backend migration — Firebase/Supabase changes deferred to future milestone
- Test coverage — acknowledged tech debt, but not blocking launch
- Web or desktop targets — mobile only

## Context

- **Current state:** The app is at v1.1.0 stable with recent bug fixes (commit 24f430c). The full game loop, monetization, and progression systems are implemented.
- **Architecture:** Clean Architecture with feature-based organization. BLoC for state management, GetIt for DI, go_router for navigation, Hive for local storage.
- **Firebase is optional:** The app runs fully offline. Firebase-dependent features (auth, leaderboard, analytics, remote config) are conditionally registered in DI.
- **Game engine:** Pure static class with no dependencies — handles board creation, tile spawning, move processing, merging, special tile logic, and bomb explosions.
- **Monetization:** RevenueCat for subscriptions/IAP, Google Mobile Ads for ad revenue.
- **Tech debt:** No tests exist yet. Privacy policy and ToS pages were recently added for GitHub Pages.

## Constraints

- **Tech stack**: Flutter 3.x / Dart 3.10+ — established, not changing
- **State management**: BLoC pattern with flutter_bloc — established convention
- **Backend**: Firebase (optional) + Supabase preferred for new backend features
- **Monetization**: RevenueCat + AdMob — already integrated
- **Platforms**: iOS and Android — no web or desktop targets

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Firebase optional/offline-first | App must work without internet; Firebase adds social features when available | ✓ Good |
| Pure static GameEngine | No dependencies = easy to test, predictable behavior | ✓ Good |
| Feature-based Clean Architecture | Scalable organization as features grow | ✓ Good |
| Hive for local storage | Fast, lightweight, no SQL overhead for game state | ✓ Good |
| No tests yet | Shipped fast to validate concept; tech debt to address | ⚠️ Revisit |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-03-25 after milestone v1.2 started*

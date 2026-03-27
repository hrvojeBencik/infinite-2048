# Infinite 2048 ("2048: Merge Quest")

## What This Is

A Flutter mobile game that reimagines the classic 2048 puzzle with level-based progression, zone themes, special tiles (blocker, bomb, wildcard, multiplier, ice), achievements, endless mode, and ad-supported monetization. Built for iOS and Android with optional Firebase backend for auth, leaderboards, and analytics.

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
- ✓ Performance profiling tools and jank elimination — v1.2
- ✓ Tile merge animations with swipe blocking — v1.2
- ✓ Screen transitions (fade lateral, slide-up modal) — v1.2
- ✓ Confetti celebration on level complete — v1.2
- ✓ Native splash screen — v1.2
- ✓ Tutorial skip button — v1.2
- ✓ Daily challenge card on home screen — v1.2
- ✓ Score sharing via native share sheet — v1.2
- ✓ Ad frequency capping via remote config — v1.2
- ✓ App icon (adaptive Android + no-alpha iOS) — v1.2
- ✓ iOS PrivacyInfo.xcprivacy manifest — v1.2
- ✓ ASO-optimized store listings — v1.2

### Active

(None — next milestone requirements TBD)

### Out of Scope

- Premium subscriptions — deferred to post-launch; build userbase first with free content
- Test coverage — acknowledged tech debt, not blocking launch
- Web or desktop targets — mobile only
- Multiplayer features — post-launch scope
- Backend migration — Firebase/Supabase changes deferred

## Context

- **Current state:** v1.2 milestone complete. App version 1.0.0+2. 16,000 LOC Dart. All features unlocked for free users. Ads (interstitial + rewarded + banner) are sole monetization. Store listings, icons, and privacy manifests ready. Awaiting manual screenshot capture, Data Safety form, and 14-day Google Play closed testing gate.
- **Architecture:** Clean Architecture with feature-based organization. BLoC for state management, GetIt for DI, go_router for navigation, Hive for local storage.
- **Firebase is optional:** The app runs fully offline. Firebase-dependent features (auth, leaderboard, analytics, remote config) are conditionally registered in DI.
- **Game engine:** Pure static class with no dependencies — handles board creation, tile spawning, move processing, merging, special tile logic, and bomb explosions.
- **Monetization:** Google Mobile Ads for ad revenue. Premium themes (Diamond, Aurora, Obsidian) exist in code but are hidden — ready for subscription re-enablement.
- **Tech debt:** No tests exist yet. Privacy policy and ToS pages on GitHub Pages.

## Constraints

- **Tech stack**: Flutter 3.x / Dart 3.10+ — established, not changing
- **State management**: BLoC pattern with flutter_bloc — established convention
- **Backend**: Firebase (optional) + Supabase preferred for new backend features
- **Monetization**: AdMob for now; RevenueCat subscription ready to re-enable when userbase grows
- **Platforms**: iOS and Android — no web or desktop targets

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Firebase optional/offline-first | App must work without internet; Firebase adds social features when available | ✓ Good |
| Pure static GameEngine | No dependencies = easy to test, predictable behavior | ✓ Good |
| Feature-based Clean Architecture | Scalable organization as features grow | ✓ Good |
| Hive for local storage | Fast, lightweight, no SQL overhead for game state | ✓ Good |
| No tests yet | Shipped fast to validate concept; tech debt to address | ⚠️ Revisit |
| Code analysis baseline over device profiling | Jank sources confirmed statically; device profiling deferred | ✓ Pragmatic |
| Defer subscriptions to post-launch | Build userbase with free content first, add paywall once audience exists | ✓ Strategic |
| Subscription code removed, not dormant | Clean codebase for launch; plan files preserved for easy rebuild | ✓ Good |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition:**
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone:**
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-03-27 after v1.2 Launch Ready milestone complete*

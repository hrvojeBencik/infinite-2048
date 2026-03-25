# Project Research Summary

**Project:** Infinite 2048 — "2048: Merge Quest" v1.2
**Domain:** Flutter mobile game — polish, performance optimization, and App Store / Google Play launch preparation
**Researched:** 2026-03-25
**Confidence:** HIGH

## Executive Summary

This is a v1.2 milestone for a feature-complete Flutter mobile game. All gameplay mechanics, zones, special tiles, progression, IAP, and Firebase integration are already built. The task is not to build new features — it is to make the existing product launch-ready: performant on mid-range devices, visually polished enough to compete in the 2048/tile genre, compliant with both stores' technical and legal requirements, and instrumented for post-launch iteration. The approach is surgical augmentation of the presentation layer without touching domain or data layers.

The recommended path is a four-phase sequence: profile for real jank first (using profile-mode on physical hardware before adding any polish), then fix the architectural sources of that jank (RepaintBoundary isolation, BLoC rebuild scoping, TileThemes reactive refactor), then add visual and UX polish on the stabilized foundation (animations, transitions, haptics, micro-interactions), and finally prepare store assets (icon, screenshots, metadata, paywall compliance). This ordering matters — polishing on top of jank produces impressive screenshots of a janky game, and generating screenshots before the visual design is final means redoing them.

The dominant risks are not technical: the Google Play 14-day closed testing gate can delay launch by 2+ weeks if not started immediately alongside store prep. Apple paywall compliance is a near-certain rejection if the RevenueCat paywall does not simultaneously display the full annual price, trial terms, and cancel instructions. Hive schema safety during upgrade is a silent crash risk for all existing users. These three issues together represent the highest-consequence, easiest-to-miss pitfalls for this milestone.

---

## Key Findings

### Recommended Stack

The existing stack is sufficient — no major new dependencies are needed. `flutter_animate` (already installed) covers all animation requirements. Three targeted additions are warranted: `flutter_native_splash` to eliminate the white flash on cold start, `confetti` for level-completion celebrations, and `share_plus` for the score-sharing flow. For store screenshot automation, `golden_screenshot` as a dev dependency eliminates the unsustainable manual screenshot process across 6+ required device sizes. All other suggested additions (Rive, Lottie, Flame, flutter_screenutil) are explicitly rejected as over-engineering or architectural conflicts.

**Core technologies:**
- `flutter_animate` (^4.5.2, already installed): All tile merge animations, screen micro-interactions, score counter animations — no external assets required
- `flutter_native_splash` (^2.4.7, add): Eliminate cold-start white flash on both iOS and Android 12+ via platform-native splash generation
- `confetti` (^0.8.0, add): Lightweight particle burst for level-complete and zone-unlock celebrations
- `share_plus` (^12.0.1, add): Score card sharing via native share sheet; requires `RepaintBoundary` capture pattern
- `golden_screenshot` (^11.0.1, dev dep): Automated App Store and Play Store screenshot generation across all device sizes
- Flutter DevTools (bundled): All performance profiling — no additional packages needed

### Expected Features

The 2048 genre is saturated, so table stakes are non-negotiable and differentiation is meaningful. Store submission has hard technical requirements that gate everything else.

**Must have for v1.2 launch (P1):**
- App icon (1024x1024 iOS no-alpha, adaptive Android) — store submission blocked without it
- App Store screenshots: 6.9" iPhone set + 13" iPad (required by Apple)
- Google Play screenshots: minimum 2 phone screenshots + 1024x500 feature graphic
- Store listing metadata: title, subtitle/short description, keywords, full description
- Privacy policy at a live accessible URL — both stores require this
- Merge tile animation (scale pop + fade) — core game feel; absence is a 1-star review driver
- Haptic feedback on merge and tile slide — standard on both platforms since 2019
- Smooth screen transitions (fade/slide, no jarring cuts)
- App startup under 3 seconds to interactive
- Crash-free session rate confirmed via Crashlytics before submission
- Review prompt after level completion — ratings strategy at the right moment
- Onboarding skip button — required for returning users post-update

**Should have for first post-launch update (P2):**
- Zone transition ceremony (full-screen animated reveal on zone unlock)
- Merge particle burst (layered on top of base animation once 60fps is confirmed)
- Daily challenge home screen card (system is built; surfacing it is the highest-leverage retention change)
- Animated XP bar fill on score gain
- Contextual empty states for achievements and leaderboard

**Defer to v2+:**
- Colorblind mode — valid need, high color-system complexity
- Localization — validate English market first
- Social sharing / deep links — unproven ROI in genre; focus on review prompt instead
- Per-tile unlock reveal animation

**Anti-features to avoid:**
- Interstitials after every level — top cause of uninstalls in puzzle genre; use remote-config frequency cap
- Animated/parallax backgrounds — GPU overhead, distracts from board
- Always-visible disabled undo button — creates confusion; show only when available

### Architecture Approach

The v1.2 milestone augments three layers — presentation (animations, transitions), core theme system (TileThemes reactive refactor), and build pipeline (fastlane, screenshot automation) — without modifying the domain or data layers. `GameEngine` remains a pure static class. The key structural changes are: wrapping `GameBoard` in `RepaintBoundary` to isolate tile repaints from the HUD, extracting `TileThemes` from a per-frame static Hive read into a reactive `ProgressionBloc` state, centralizing all go_router transitions in `AppTransitions`, and formalizing `HapticService` into DI.

**Major components:**
1. `RepaintBoundary` around `GameBoard` — isolates 60fps tile animation repaints from score/header rebuilds; prevents cascading rebuild storm on every swipe
2. `AppTransitions` (new: `lib/core/navigation/app_transitions.dart`) — centralized `CustomTransitionPage` builders for consistent fade/slideUp across all routes
3. `PerformanceService` (new: `lib/core/services/performance_service.dart`) — dev-only `SchedulerBinding.addTimingsCallback` wrapper; no-ops in release; surfaces jank without Firebase Performance overhead
4. `HapticService` (formalize: `lib/core/services/haptic_service.dart`) — extract from inline game_page.dart calls into registered DI service
5. `fastlane/` + `integration_test/screenshots/` (new) — automated store screenshot pipeline; eliminates manual capture across 6+ device sizes
6. TileThemes via `ProgressionBloc` state — replaces per-frame Hive read (~960 regex ops/second at 60fps) with reactive constructor injection

### Critical Pitfalls

1. **Testing animations in debug mode and shipping blind** — Debug mode is 2-3x slower than release AOT. Animations that look acceptable in `flutter run` will stutter on users' devices. Prevention: all animation sign-off must be done in `flutter run --profile` on a physical device (Pixel 4a and iPhone 12 mini as minimum targets), never in simulator or debug.

2. **BLoC rebuilding the entire board on every game tick** — A `BlocBuilder` without `buildWhen` wrapping the game grid triggers 16 tile widget rebuilds per swipe. When animations run on top, this causes dropped frames on mid-range Android. Prevention: add `buildWhen` to all high-frequency BLoC consumers; wrap `GameBoard` in `RepaintBoundary`; use `AnimatedBuilder`'s `child` parameter for non-animated subtrees.

3. **Google Play 14-day closed testing gate** — Accounts created after November 2023 cannot publish to production without 12 testers opted in for 14 consecutive days. This cannot be accelerated. Prevention: launch the closed test track on day 1 of the store preparation phase — not after screenshots and metadata are complete.

4. **RevenueCat paywall Apple rejection (Guideline 3.1.2)** — Paywalls that show only the normalized monthly price without displaying the full annual charge, trial duration, and cancel instructions are rejected. Prevention: run the paywall against RevenueCat's official review checklist before submission; all required disclosures must be visible without scrolling on a standard phone.

5. **Hive schema corruption on upgrade** — Any change to a `@HiveType` or `@HiveField` annotated class without migration logic causes silent crashes for existing users who upgrade from v1.1.0. Prevention: treat all Hive adapters as write-protected; add new fields as nullable with defaults; test by installing v1.1.0 build, writing data, then upgrading to v1.2.0 — no migration, no schema change.

---

## Implications for Roadmap

Based on combined research, the architecture specifies an explicit build order and the pitfalls confirm it. Suggested phase structure:

### Phase 1: Performance Audit and Baseline
**Rationale:** Architecture research is explicit — profile before polishing. Adding animations on top of undiagnosed jank bakes the problem in. This phase cannot be skipped or merged with the animation phase.
**Delivers:** A measured, documented performance baseline; identification of actual jank sources (not hypothetical ones); `PerformanceService` wired to dev options; `SoundService` audited for audioplayer pooling memory leak.
**Addresses:** Table-stakes feature "No visible jank on game board," startup time under 3 seconds
**Avoids:** Pitfall 1 (debug-mode testing), Pitfall 2 (BLoC rebuild storm), Pitfall 6 (audioplayers OOM after 30min play)
**Research flag:** Standard Flutter profiling patterns — skip research-phase

### Phase 2: Architectural Foundations (Jank Fixes)
**Rationale:** Identified jank sources from Phase 1 must be fixed before adding new animations — otherwise new animations are built on a broken repaint model. TileTheme refactor is a constructor-level change that downstream animation work depends on.
**Delivers:** `RepaintBoundary` isolation on `GameBoard`; TileThemes reactive via `ProgressionBloc`; `buildWhen` guards on high-frequency BLoC consumers; `AnimatedBuilder` child-parameter pattern applied; `HapticService` extracted to DI; `didUpdateWidget` animation double-trigger race fixed in `TileWidget`.
**Addresses:** Core animation architecture; theme-switching UX
**Avoids:** Pitfall 2 (BLoC rebuild storm); Anti-pattern 2 (Hive read per frame)
**Research flag:** Well-documented Flutter patterns — skip research-phase

### Phase 3: Animations and Visual Polish
**Rationale:** Built on the clean repaint architecture from Phase 2. All animation work is additive now that the widget tree is correctly isolated.
**Delivers:** Tile merge scale-pop animation (150-200ms); `AppTransitions` with fade/slideUp for go_router; haptic feedback on merge and slide; confetti on level complete; screen transition polish; `AppColors` consistency pass.
**Addresses:** Merge animation (P1 must-have); screen transitions (P1); haptics (P1); celebration moments (P2 — zone transition ceremony, particle burst)
**Avoids:** Anti-pattern 1 (animating inside BlocBuilder); UX pitfall of mandatory animation blocking input (queue swipes or keep animations under 200ms); over-animating home screen (keep home transitions under 300ms total)
**Research flag:** Skip research-phase — flutter_animate patterns are well-documented; custom Canvas particle work is straightforward given existing ParticleEffect component

### Phase 4: UX Flow and Usability
**Rationale:** UX changes (onboarding skip, daily challenge home card, contextual empty states, ad frequency fixes, paywall UX) depend on having polished transitions in place so screens feel complete when tested. This is also when any Hive-touching changes must include upgrade testing.
**Delivers:** Onboarding skip button; daily challenge surfaced on home screen; contextual empty states for achievements/leaderboard; ad-free verification for premium users; paywall disclosure compliance; premium-user ad gate audit.
**Addresses:** Onboarding skip (P1); daily challenge home card (P2); empty states (P2); ad frequency best practices
**Avoids:** Pitfall 5 (Hive schema changes without migration — any profile/settings data touch must include upgrade test from v1.1.0); UX pitfall of modal paywall on second open; gesture sensitivity regression
**Research flag:** Paywall compliance specifics (RevenueCat guidelines) may need verification during implementation — reference PITFALLS.md Section "RevenueCat paywall rejection"

### Phase 5: Store Preparation and Submission
**Rationale:** Must come last — screenshots must capture the final polished state. Google Play closed testing must start on day 1 of this phase (14-day gate is a hard dependency). iOS privacy manifest and Data Safety form are submission blockers.
**Delivers:** App icon (1024x1024 iOS, adaptive Android); App Store screenshots (6.9" iPhone + 13" iPad); Google Play screenshots + feature graphic; `fastlane/` setup with Deliver + Supply; store listing metadata (title, subtitle, keywords, description, release notes); privacy manifest (`PrivacyInfo.xcprivacy`); Google Play Data Safety form; closed test track with 12+ testers; final release-build smoke test on physical devices.
**Addresses:** All store-submission P1 requirements; ASO keyword strategy; paywall compliance checklist
**Avoids:** Pitfall 3 (14-day Google Play gate — start immediately); Pitfall 4 (paywall rejection — run checklist before submission); keyword stuffing rejection; screenshot mismatch rejection; missing iOS privacy manifest rejection
**Research flag:** ASO keyword research is domain-specific — may benefit from a targeted research-phase task for keywords and store listing copy

### Phase Ordering Rationale

- **Performance before polish** — Architecture research explicitly states this order: profile first, then fix structural issues, then add animations. Reversing this wastes effort polishing things that get destroyed when jank is fixed.
- **Architecture before animations** — TileWidget constructor changes (TileTheme injection) affect the animation layer. Doing animation work before this refactor means revisiting TileWidget twice.
- **UX before store prep** — Screenshots must show the final UX state. Any UX change after screenshots are generated requires a full reshoot.
- **Store prep as final phase** — The 14-day Google Play gate is the critical path constraint. Starting store prep last means the gate starts last. Starting it 5 weeks before target launch date is the minimum safe margin.

### Research Flags

Phases needing deeper research during planning:
- **Phase 5 (Store Preparation):** ASO keyword research, competitor listing analysis, and store description copywriting benefit from targeted research; these are discovery-critical and genre-specific
- **Phase 4 (UX Flow):** If RevenueCat paywall structure needs significant changes for compliance, that integration has non-obvious specifics — reference RevenueCat docs directly

Phases with standard patterns (skip research-phase):
- **Phase 1 (Performance Audit):** Flutter DevTools profiling is thoroughly documented; SchedulerBinding.addTimingsCallback pattern is straightforward
- **Phase 2 (Architectural Foundations):** RepaintBoundary, BLoC buildWhen, AnimatedBuilder child-param are well-established Flutter patterns; no surprises expected
- **Phase 3 (Animations):** flutter_animate API is well-documented; go_router CustomTransitionPage has solid docs; confetti package API is minimal

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All packages verified on pub.dev; existing stack confirmed against pubspec.yaml; version constraints checked |
| Features | HIGH (store requirements) / MEDIUM (polish patterns) | Apple/Google requirements from official docs (HIGH); game-feel polish from community consensus and competitor analysis (MEDIUM) |
| Architecture | HIGH | Grounded in existing codebase inspection + official Flutter docs for all recommended patterns |
| Pitfalls | HIGH | Critical pitfalls sourced from official Apple/Google/RevenueCat documentation and Flutter official performance docs |

**Overall confidence:** HIGH

### Gaps to Address

- **SoundService actual implementation:** Pitfall 6 (audioplayers pooling) needs verification against the actual `SoundService` code — the research flags the risk pattern but the actual code must be inspected during Phase 1 to confirm whether new `AudioPlayer()` instances are created per sound event.
- **Paywall current compliance state:** The RevenueCat paywall rejection pitfall assumes the current paywall shows only a monthly price. The actual paywall UI should be reviewed before Phase 4 to assess how much work compliance requires.
- **Google Play account type:** Pitfall 3 (14-day testing gate) applies to personal accounts created after November 2023. The project's Play Console account type should be confirmed at the start of Phase 5.
- **Existing app icon state:** STACK.md notes `assets/icon/icon.png` exists per pubspec assets, but whether it meets the 1024x1024, no-alpha iOS requirement and whether adaptive icon foreground/monochrome layers exist is unconfirmed. Visual inspection needed before Phase 5.
- **ASO keyword strategy:** Store listing copy and keyword selection require genre-specific research not covered by these four research files. Recommend a targeted research task during Phase 5 planning.

---

## Sources

### Primary (HIGH confidence)
- pub.dev package pages — flutter_native_splash 2.4.7, confetti 0.8.0, share_plus 12.0.1, golden_screenshot 11.0.1, flutter_animate 4.5.2, flutter_launcher_icons 0.14.4 (verified)
- docs.flutter.dev/perf/ui-performance — DevTools profiling workflow, profile-mode requirements
- docs.flutter.dev/perf/best-practices — RepaintBoundary, AnimatedBuilder child-param, buildWhen patterns
- docs.flutter.dev/testing/build-modes — Debug vs profile vs release performance characteristics
- developer.apple.com/help/app-store-connect — Screenshot specifications, app icon requirements, privacy manifest
- support.google.com/googleplay/android-developer — Screenshot requirements, Data Safety form, closed testing gate (answer/14151465)
- revenuecat.com/docs/tools/paywalls — Paywall App Review requirements
- revenuecat.com/blog/growth — App Store rejection guide for subscription paywalls
- api.flutter.dev — RepaintBoundary, SchedulerBinding.addTimingsCallback, CustomTransitionPage

### Secondary (MEDIUM confidence)
- ITNEXT / Flutterexperts — Flutter 2025 performance best practices
- Appbot — Review prompt timing best practices
- Deconstructor of Fun — Hybrid-casual puzzle UX patterns (2025)
- Game Juice Design (The Design Lab) — Merge celebration design patterns
- AppRadar — Google Play screenshot size guidelines
- Saropa/Medium — RepaintBoundary as jank prevention, Flutter memory reduction strategies
- Easy Flutter/Medium — audioplayers pooling and flutter_soloud recommendation
- logrocket.com — Fastlane for Flutter complete guide

### Tertiary (LOW-MEDIUM confidence)
- Competitor app store listings analyzed: 2248 Number Puzzle 2048, 2048 Pro (Playsquare), 2048 by Ketchapp — observed but not tested
- DEV Community — Rive vs Lottie 2025 performance comparison (60fps vs 17fps)
- OpenForge — Google Play developer policy changes 2026

---
*Research completed: 2026-03-25*
*Ready for roadmap: yes*

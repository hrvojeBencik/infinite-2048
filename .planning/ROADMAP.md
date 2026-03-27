# Roadmap: Infinite 2048 — v1.2 Launch Ready

## Overview

v1.2 takes a feature-complete game from working to launch-ready. The path is
deliberately sequenced: profile the existing app for real jank first, fix the
architectural sources of that jank, then add visual polish and animations on
the stable foundation, refine UX flow and usability, and finally prepare store
assets that capture the finished product. Reversing any step wastes effort —
polishing a janky codebase means rebuilding polish once the jank is fixed.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Performance Audit** - Profile the app in --profile mode, establish a 60fps baseline, wire dev frame-timing tools, and audit SoundService for memory leaks (completed 2026-03-26)
- [ ] **Phase 2: Architectural Foundations** - Fix the structural sources of jank: RepaintBoundary isolation, TileThemes reactive refactor, BLoC buildWhen guards, HapticService extraction
- [ ] **Phase 3: Animations and Visual Polish** - Add tile merge animations, screen transitions, haptic feedback, confetti, XP bar animation, particle effects, and native splash on the stabilized architecture
- [x] **Phase 4: UX Flow and Usability** - Surface daily challenges on home, add onboarding skip, cap ad frequency, add review prompt, enable score sharing, and verify paywall compliance (completed 2026-03-26)
- [ ] **Phase 5: Store Preparation** - App icon, screenshots, metadata, privacy manifest, Data Safety form, paywall build, and closed testing gate (start Google Play closed test on day 1 of this phase)

## Phase Details

### Phase 1: Performance Audit
**Goal**: Developers have a documented performance baseline and identified jank sources before any polish begins
**Depends on**: Nothing (first phase)
**Requirements**: PERF-01, PERF-05, PERF-06, PERF-07
**Success Criteria** (what must be TRUE):
  1. A profiling session in --profile mode on a physical mid-range device has been run and frame times documented
  2. Jank sources (specific widgets, rebuilds, or audio events) are identified and recorded — not hypothetical
  3. Developer can toggle a frame timing overlay from the DevTools page during a debug session
  4. SoundService has been audited and the AudioPlayer pooling risk is either confirmed resolved or flagged as a Phase 2 fix
  5. A dev tool is available to trigger a performance regression check (confirms no regression from baseline)
**Plans:** 2/2 plans complete
Plans:
- [x] 01-01-PLAN.md — Wire PerformanceOverlay toggle and regression check button into dev options page
- [x] 01-02-PLAN.md — Profile on physical device and write PERF-BASELINE.md report

### Phase 2: Architectural Foundations
**Goal**: The widget tree is correctly structured so animations can be added without triggering cascading rebuilds
**Depends on**: Phase 1
**Requirements**: PERF-02, PERF-03, PERF-04
**Success Criteria** (what must be TRUE):
  1. Swiping on the game board does not trigger a repaint of the score display, header, or controls (verified via DevTools Repaint Rainbow)
  2. TileThemes no longer reads from Hive on every frame — tile theme is passed reactively via ProgressionBloc state
  3. High-frequency BLoC consumers have buildWhen guards and full widget-tree rebuilds on partial state changes are eliminated
**Plans:** 1/3 plans executed
Plans:
- [x] 02-01-PLAN.md — Extract HapticService, create ProgressionBloc, wire DI and global BlocProvider
- [x] 02-02-PLAN.md — Refactor TileThemes to remove Hive/regex, update TileWidget and ThemeSelectionPage
- [x] 02-03-PLAN.md — Split GamePage BlocConsumer into targeted BlocBuilders with RepaintBoundary zones

### Phase 3: Animations and Visual Polish
**Goal**: Every core interaction in the game feels responsive and satisfying with consistent visual feedback
**Depends on**: Phase 2
**Requirements**: ANIM-01, ANIM-02, ANIM-03, ANIM-04, ANIM-05, ANIM-06, ANIM-07
**Success Criteria** (what must be TRUE):
  1. Merging two tiles produces a visible scale-pop animation that completes before the next swipe can be registered
  2. Navigating between screens uses consistent fade (lateral) or slide-up (modal) transitions — no jarring cuts
  3. Completing a level triggers a confetti burst celebration visible on screen
  4. The app cold-starts into a native splash screen instead of a white flash
  5. Haptic feedback fires on tile merge and is perceptible on physical devices
**Plans:** 1/2 plans executed
Plans:
- [x] 03-01-PLAN.md — Add dependencies, generate native splash, animate XP bar, polish particle palette
- [x] 03-02-PLAN.md — Wire swipe blocking, slide-up dialog transitions, haptic verification, confetti integration

### Phase 4: UX Flow and Usability
**Goal**: Users can navigate the app intuitively and key engagement surfaces (daily challenges, score sharing, review prompt) are accessible
**Depends on**: Phase 3
**Requirements**: UX-01, UX-02, UX-03, UX-04, UX-05
**Success Criteria** (what must be TRUE):
  1. A returning user who has seen the onboarding tutorial can skip it without completing all steps
  2. The daily challenge card is visible on the home screen without navigating elsewhere
  3. After completing a level, the app prompts the user to leave a review (respects OS frequency limits)
  4. An ad-free premium user never sees an interstitial; free users see ads at most every 3 levels by default
  5. User can share their score as an image using the native share sheet from the game over or level complete screen
**Plans:** 2/2 plans complete
Plans:
- [x] 04-01-PLAN.md — Skip tutorial button, daily challenge card reposition, ad frequency cap, review prompt verification
- [x] 04-02-PLAN.md — Score sharing with ShareScoreCard widget and share_plus integration

### Phase 5: Store Preparation
**Goal**: Both stores have complete, compliant, polished listings and the app is ready for public release submission
**Depends on**: Phase 4
**Requirements**: STORE-01, STORE-02, STORE-03, STORE-04, STORE-05, STORE-06, STORE-07, STORE-08, STORE-09, STORE-10
**Success Criteria** (what must be TRUE):
  1. App icon passes Apple review requirements (1024x1024, no alpha channel) and Android adaptive icon is configured
  2. Screenshots for all required device sizes exist (captured manually — fastlane descoped per D-05)
  3. Both store listings have complete ASO-optimized metadata (title, subtitle/short description, keywords, full description, categories)
  4. Privacy policy URL is live, Google Play Data Safety form is submitted, and iOS PrivacyInfo.xcprivacy is configured
  5. Google Play closed testing track has been live with 12+ testers for 14 consecutive days before production submission
  6. RevenueCat paywall displays full annual price, trial terms, and cancel instructions without scrolling (Guideline 3.1.2 compliant)
**Plans:** 3/4 plans executed
Plans:
- [x] 05-01-PLAN.md — App icon config (adaptive + iOS alpha removal) and iOS PrivacyInfo.xcprivacy
- [x] 05-02-PLAN.md — Build RevenueCat paywall screen (Apple Guideline 3.1.2 compliant)
- [x] 05-03-PLAN.md — ASO-optimized store listing metadata and version bump
- [ ] 05-04-PLAN.md — Screenshot guide, Data Safety guide, and human verification checkpoint

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Performance Audit | 2/2 | Complete   | 2026-03-26 |
| 2. Architectural Foundations | 1/3 | In Progress|  |
| 3. Animations and Visual Polish | 1/2 | In Progress|  |
| 4. UX Flow and Usability | 2/2 | Complete   | 2026-03-26 |
| 5. Store Preparation | 3/4 | In Progress|  |

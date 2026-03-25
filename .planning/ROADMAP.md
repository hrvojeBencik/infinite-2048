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

- [ ] **Phase 1: Performance Audit** - Profile the app in --profile mode, establish a 60fps baseline, wire dev frame-timing tools, and audit SoundService for memory leaks
- [ ] **Phase 2: Architectural Foundations** - Fix the structural sources of jank: RepaintBoundary isolation, TileThemes reactive refactor, BLoC buildWhen guards, HapticService extraction
- [ ] **Phase 3: Animations and Visual Polish** - Add tile merge animations, screen transitions, haptic feedback, confetti, XP bar animation, particle effects, and native splash on the stabilized architecture
- [ ] **Phase 4: UX Flow and Usability** - Surface daily challenges on home, add onboarding skip, cap ad frequency, add review prompt, enable score sharing, and verify paywall compliance
- [ ] **Phase 5: Store Preparation** - App icon, screenshots, metadata, privacy manifest, Data Safety form, fastlane pipeline, and closed testing gate (start Google Play closed test on day 1 of this phase)

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
**Plans**: TBD

### Phase 2: Architectural Foundations
**Goal**: The widget tree is correctly structured so animations can be added without triggering cascading rebuilds
**Depends on**: Phase 1
**Requirements**: PERF-02, PERF-03, PERF-04
**Success Criteria** (what must be TRUE):
  1. Swiping on the game board does not trigger a repaint of the score display, header, or controls (verified via DevTools Repaint Rainbow)
  2. TileThemes no longer reads from Hive on every frame — tile theme is passed reactively via ProgressionBloc state
  3. High-frequency BLoC consumers have buildWhen guards and full widget-tree rebuilds on partial state changes are eliminated
**Plans**: TBD

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
**Plans**: TBD
**UI hint**: yes

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
**Plans**: TBD
**UI hint**: yes

### Phase 5: Store Preparation
**Goal**: Both stores have complete, compliant, polished listings and the app is ready for public release submission
**Depends on**: Phase 4
**Requirements**: STORE-01, STORE-02, STORE-03, STORE-04, STORE-05, STORE-06, STORE-07, STORE-08, STORE-09, STORE-10
**Success Criteria** (what must be TRUE):
  1. App icon passes Apple review requirements (1024x1024, no alpha channel) and Android adaptive icon is configured
  2. Screenshots for all required device sizes exist and are generated via the fastlane pipeline (not manually)
  3. Both store listings have complete ASO-optimized metadata (title, subtitle/short description, keywords, full description, categories)
  4. Privacy policy URL is live, Google Play Data Safety form is submitted, and iOS PrivacyInfo.xcprivacy is configured
  5. Google Play closed testing track has been live with 12+ testers for 14 consecutive days before production submission
  6. RevenueCat paywall displays full annual price, trial terms, and cancel instructions without scrolling (Guideline 3.1.2 compliant)
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Performance Audit | 0/? | Not started | - |
| 2. Architectural Foundations | 0/? | Not started | - |
| 3. Animations and Visual Polish | 0/? | Not started | - |
| 4. UX Flow and Usability | 0/? | Not started | - |
| 5. Store Preparation | 0/? | Not started | - |

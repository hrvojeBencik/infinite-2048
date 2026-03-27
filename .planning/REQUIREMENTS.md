# Requirements: Infinite 2048

**Defined:** 2026-03-25
**Core Value:** The core 2048 gameplay loop must feel tight, responsive, and satisfying

## v1.2 Requirements

Requirements for v1.2 Launch Ready milestone. Each maps to roadmap phases.

### Performance & Architecture

- [x] **PERF-01**: App achieves consistent 60fps during gameplay on mid-range devices (profiled in --profile mode)
- [x] **PERF-02**: TileThemes refactored from static Hive/regex lookup to reactive theme passed via ProgressionBloc
- [x] **PERF-03**: RepaintBoundary isolates game board, score display, and control areas from unnecessary repaints
- [x] **PERF-04**: BLoC buildWhen guards prevent full widget tree rebuilds on partial state changes
- [x] **PERF-05**: SoundService audited for audioplayer memory leaks with pooling if needed
- [x] **PERF-06**: Dev-only frame timing overlay available via DevTools page
- [x] **PERF-07**: Automated performance regression check available as dev tool

### Animations & Visual Polish

- [x] **ANIM-01**: Tile merge produces satisfying pop/scale animation with easing
- [x] **ANIM-02**: Screen transitions use consistent fade (lateral) and slide-up (modal) patterns
- [x] **ANIM-03**: Haptic feedback fires on tile merge events
- [x] **ANIM-04**: Confetti animation plays on level completion
- [x] **ANIM-05**: XP bar animates smoothly on XP gain
- [x] **ANIM-06**: Particle effects polished with consistent visual style
- [x] **ANIM-07**: Native splash screen displays during app startup

### UX Flow & Usability

- [x] **UX-01**: User can skip onboarding tutorial
- [x] **UX-02**: Ad frequency capped via remote config (default: every 3 levels)
- [x] **UX-03**: Review prompt appears after level completion (respects OS limits)
- [x] **UX-04**: Daily challenge card visible on home screen
- [x] **UX-05**: User can share score as image from game over / level complete screen

### Store Preparation

- [x] **STORE-01**: App icon at 1024x1024 (no alpha for iOS), adaptive icon for Android
- [x] **STORE-02**: Store screenshots generated for all required device sizes (iPhone 6.9", 6.7", 6.5", iPad 13"; Android phone + tablet)
- [x] **STORE-03**: Privacy policy URL live and accessible
- [x] **STORE-04**: App Store metadata complete (title, subtitle, keywords, description, categories)
- [x] **STORE-05**: Play Store metadata complete (title, short description, full description, categories)
- [x] **STORE-06**: iOS PrivacyInfo.xcprivacy manifest configured
- [x] **STORE-07**: Google Play Data Safety form completed
- [x] **STORE-08**: Fastlane pipeline automates screenshot capture and framing
- [x] **STORE-09**: ASO-optimized store copy for both platforms
- [x] **STORE-10**: RevenueCat paywall compliant with Apple 3.1.2 (full pricing, cancel instructions, links visible without scrolling)

## Future Requirements

### Testing
- **TEST-01**: Unit tests for GameEngine core logic
- **TEST-02**: Widget tests for key UI components
- **TEST-03**: Integration tests for critical user flows

## Out of Scope

| Feature | Reason |
|---------|--------|
| New gameplay mechanics | v1.2 is polish only — no new tile types or game modes |
| Backend migration | Firebase/Supabase changes deferred to future milestone |
| Comprehensive test coverage | Acknowledged tech debt, not blocking launch |
| Web or desktop targets | Mobile only for launch |
| Multiplayer features | Post-launch scope |
| Social features beyond score sharing | Keep launch scope focused |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| PERF-01 | Phase 1 | Complete |
| PERF-05 | Phase 1 | Complete |
| PERF-06 | Phase 1 | Complete |
| PERF-07 | Phase 1 | Complete |
| PERF-02 | Phase 2 | Complete |
| PERF-03 | Phase 2 | Complete |
| PERF-04 | Phase 2 | Complete |
| ANIM-01 | Phase 3 | Complete |
| ANIM-02 | Phase 3 | Complete |
| ANIM-03 | Phase 3 | Complete |
| ANIM-04 | Phase 3 | Complete |
| ANIM-05 | Phase 3 | Complete |
| ANIM-06 | Phase 3 | Complete |
| ANIM-07 | Phase 3 | Complete |
| UX-01 | Phase 4 | Complete |
| UX-02 | Phase 4 | Complete |
| UX-03 | Phase 4 | Complete |
| UX-04 | Phase 4 | Complete |
| UX-05 | Phase 4 | Complete |
| STORE-01 | Phase 5 | Complete |
| STORE-02 | Phase 5 | Complete |
| STORE-03 | Phase 5 | Complete |
| STORE-04 | Phase 5 | Complete |
| STORE-05 | Phase 5 | Complete |
| STORE-06 | Phase 5 | Complete |
| STORE-07 | Phase 5 | Complete |
| STORE-08 | Phase 5 | Complete |
| STORE-09 | Phase 5 | Complete |
| STORE-10 | Phase 5 | Complete |

**Coverage:**
- v1.2 requirements: 29 total
- Mapped to phases: 29
- Unmapped: 0

---
*Requirements defined: 2026-03-25*
*Last updated: 2026-03-25 — traceability mapped after roadmap creation*

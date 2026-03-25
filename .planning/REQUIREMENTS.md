# Requirements: Infinite 2048

**Defined:** 2026-03-25
**Core Value:** The core 2048 gameplay loop must feel tight, responsive, and satisfying

## v1.2 Requirements

Requirements for v1.2 Launch Ready milestone. Each maps to roadmap phases.

### Performance & Architecture

- [ ] **PERF-01**: App achieves consistent 60fps during gameplay on mid-range devices (profiled in --profile mode)
- [ ] **PERF-02**: TileThemes refactored from static Hive/regex lookup to reactive theme passed via ProgressionBloc
- [ ] **PERF-03**: RepaintBoundary isolates game board, score display, and control areas from unnecessary repaints
- [ ] **PERF-04**: BLoC buildWhen guards prevent full widget tree rebuilds on partial state changes
- [ ] **PERF-05**: SoundService audited for audioplayer memory leaks with pooling if needed
- [ ] **PERF-06**: Dev-only frame timing overlay available via DevTools page
- [ ] **PERF-07**: Automated performance regression check available as dev tool

### Animations & Visual Polish

- [ ] **ANIM-01**: Tile merge produces satisfying pop/scale animation with easing
- [ ] **ANIM-02**: Screen transitions use consistent fade (lateral) and slide-up (modal) patterns
- [ ] **ANIM-03**: Haptic feedback fires on tile merge events
- [ ] **ANIM-04**: Confetti animation plays on level completion
- [ ] **ANIM-05**: XP bar animates smoothly on XP gain
- [ ] **ANIM-06**: Particle effects polished with consistent visual style
- [ ] **ANIM-07**: Native splash screen displays during app startup

### UX Flow & Usability

- [ ] **UX-01**: User can skip onboarding tutorial
- [ ] **UX-02**: Ad frequency capped via remote config (default: every 3 levels)
- [ ] **UX-03**: Review prompt appears after level completion (respects OS limits)
- [ ] **UX-04**: Daily challenge card visible on home screen
- [ ] **UX-05**: User can share score as image from game over / level complete screen

### Store Preparation

- [ ] **STORE-01**: App icon at 1024x1024 (no alpha for iOS), adaptive icon for Android
- [ ] **STORE-02**: Store screenshots generated for all required device sizes (iPhone 6.9", 6.7", 6.5", iPad 13"; Android phone + tablet)
- [ ] **STORE-03**: Privacy policy URL live and accessible
- [ ] **STORE-04**: App Store metadata complete (title, subtitle, keywords, description, categories)
- [ ] **STORE-05**: Play Store metadata complete (title, short description, full description, categories)
- [ ] **STORE-06**: iOS PrivacyInfo.xcprivacy manifest configured
- [ ] **STORE-07**: Google Play Data Safety form completed
- [ ] **STORE-08**: Fastlane pipeline automates screenshot capture and framing
- [ ] **STORE-09**: ASO-optimized store copy for both platforms
- [ ] **STORE-10**: RevenueCat paywall compliant with Apple 3.1.2 (full pricing, cancel instructions, links visible without scrolling)

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
| PERF-01 | — | Pending |
| PERF-02 | — | Pending |
| PERF-03 | — | Pending |
| PERF-04 | — | Pending |
| PERF-05 | — | Pending |
| PERF-06 | — | Pending |
| PERF-07 | — | Pending |
| ANIM-01 | — | Pending |
| ANIM-02 | — | Pending |
| ANIM-03 | — | Pending |
| ANIM-04 | — | Pending |
| ANIM-05 | — | Pending |
| ANIM-06 | — | Pending |
| ANIM-07 | — | Pending |
| UX-01 | — | Pending |
| UX-02 | — | Pending |
| UX-03 | — | Pending |
| UX-04 | — | Pending |
| UX-05 | — | Pending |
| STORE-01 | — | Pending |
| STORE-02 | — | Pending |
| STORE-03 | — | Pending |
| STORE-04 | — | Pending |
| STORE-05 | — | Pending |
| STORE-06 | — | Pending |
| STORE-07 | — | Pending |
| STORE-08 | — | Pending |
| STORE-09 | — | Pending |
| STORE-10 | — | Pending |

**Coverage:**
- v1.2 requirements: 24 total
- Mapped to phases: 0
- Unmapped: 24 (pending roadmap creation)

---
*Requirements defined: 2026-03-25*
*Last updated: 2026-03-25 after initial definition*

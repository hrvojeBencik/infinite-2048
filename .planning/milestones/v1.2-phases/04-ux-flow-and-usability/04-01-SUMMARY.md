---
phase: 04-ux-flow-and-usability
plan: 01
subsystem: ui
tags: [flutter, bloc, ad-service, remote-config, onboarding, home-screen]

# Dependency graph
requires:
  - phase: 03-animations-and-visual-polish
    provides: AnimatedSize, flutter_animate, GlassCard widget patterns
provides:
  - Skip Tutorial button in TutorialOverlay (top-right Positioned, marks onboarding complete via OnboardingLocalDataSource)
  - Daily challenge card repositioned above Play button on home screen with target tile, board size, and time remaining
  - AdService.onLevelCompleted with isPremium guard (premium users skip interstitials entirely)
  - AdService threshold driven by RemoteConfigService.adFrequencyLevelCount (default 3)
  - Review prompt confirmed wired via existing _checkRateAppPrompt in game_page.dart level complete flow
affects: [04-02-score-sharing, store-preparation]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "AdService premium guard: if (!_initialized || isPremium) return — always check premium before ad logic"
    - "RemoteConfigService default pattern: static const _defaultX = val; add to setDefaults map; getter uses ?? fallback"
    - "AnimatedSize wrapping card content for smooth placeholder-to-loaded transitions"

key-files:
  created: []
  modified:
    - lib/features/onboarding/presentation/widgets/tutorial_overlay.dart
    - lib/features/home/presentation/pages/home_page.dart
    - lib/core/services/ad_service.dart
    - lib/core/services/remote_config_service.dart
    - lib/features/game/presentation/pages/game_page.dart

key-decisions:
  - "AdService imports di.dart and remote_config_service.dart directly to resolve RemoteConfigService — no constructor injection needed since AdService is already a DI singleton"
  - "Daily challenge card loading placeholder uses fixed 80px height inside AnimatedSize so layout space is reserved before data loads — avoids content jump on the home screen"
  - "Skip Tutorial uses onSkip callback if provided, falls back to onComplete — caller can differentiate skip vs natural completion if needed"

patterns-established:
  - "Premium guard in ad logic: isPremium bool extracted from AuthBloc state at call site, passed as named param"
  - "RemoteConfigService remote-overridable int: add key constant, default constant, include in setDefaults, expose getter with ?? fallback"

requirements-completed: [UX-01, UX-02, UX-03, UX-04]

# Metrics
duration: 18min
completed: 2026-03-26
---

# Phase 04 Plan 01: UX Improvements — Tutorial Skip, Daily Challenge Card, Ad Frequency Summary

**Skip Tutorial button on TutorialOverlay, daily challenge card above Play with target tile/board/time, premium ad bypass driven by RemoteConfig threshold**

## Performance

- **Duration:** 18 min
- **Started:** 2026-03-26T21:11:00Z
- **Completed:** 2026-03-26T21:29:00Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- Added `onSkip` callback and visible `Skip Tutorial` TextButton (top-right Positioned) to TutorialOverlay — tapping calls `markTutorialCompleted()` and dismisses overlay from any step
- Repositioned `_DailyChallengeCard` above `_PlayButton` in home screen column; added AnimatedSize loading placeholder (80px), target tile value, board size, and `_formatTimeRemaining()` time display
- Changed `AdService.onLevelCompleted` to `{required bool isPremium}` — premium users return early before any ad logic; threshold now reads `sl<RemoteConfigService>().adFrequencyLevelCount` (remote-configurable, default 3)
- Confirmed `_checkRateAppPrompt(state.stars)` already wired in `_trackAchievements` at game_page.dart line 604 — no code change needed

## Task Commits

Each task was committed atomically:

1. **Task 1: Add skip button to TutorialOverlay and reposition daily challenge card** - `2b134fd` (feat)
2. **Task 2: Add premium guard and remote config threshold to ad frequency** - `5a3e55d` (feat)

## Files Created/Modified
- `lib/features/onboarding/presentation/widgets/tutorial_overlay.dart` - Added onSkip param, _skipTutorial(), Positioned Skip Tutorial button
- `lib/features/home/presentation/pages/home_page.dart` - Reordered column (daily card first), AnimatedSize placeholder, targetTileValue/boardSize/timeRemaining display
- `lib/core/services/ad_service.dart` - isPremium guard, remote config threshold, imports di.dart and remote_config_service.dart
- `lib/core/services/remote_config_service.dart` - Added adFrequencyLevelCount getter, _keyAdFrequency, _defaultAdFrequency=3
- `lib/features/game/presentation/pages/game_page.dart` - Extract isPremium from AuthBloc state, pass to onLevelCompleted

## Decisions Made
- AdService resolves RemoteConfigService via `sl<>()` directly (not constructor injection) — consistent with existing AdService pattern; both are lazy singletons registered before use
- Loading placeholder is 80px fixed height in AnimatedSize so home screen doesn't reflow when daily challenge data arrives
- Skip button falls back to `widget.onComplete()` if no `onSkip` provided — backward-compatible with existing call sites

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- All 4 UX-01 through UX-04 requirements satisfied
- Plan 02 (score sharing) can now proceed — home screen engagement surface is ready
- Remote config `ad_frequency_level_count` key should be set in Firebase console for production tuning

---
*Phase: 04-ux-flow-and-usability*
*Completed: 2026-03-26*

# Milestones

## v1.2 Launch Ready (Shipped: 2026-03-27)

**Phases completed:** 5 phases, 13 plans, 17 tasks

**Key accomplishments:**

- PerformanceOverlay toggle and scripted-swipe regression check wired into dev options page, gated by kDebugMode/kReleaseMode with SchedulerBinding frame timing capture and pass/fail reporting
- Static code analysis confirms TileThemes._activeTheme() as primary jank source (4,800 regex ops/sec), RepaintBoundary absence throughout widget tree, and SoundService as haptic-only with PERF-05 closed N/A — PERF-BASELINE.md written with Phase 2 fix priorities, device measurement fields marked PENDING
- One-liner:
- One-liner:
- GamePage render isolation via BlocListener + 5 targeted BlocBuilders with buildWhen guards and 4 RepaintBoundary zones — score repaints only on score/moveCount changes, board only on board changes, powerups only on powerup count changes
- One-liner:
- Swipe input blocked for 420ms during merge animation, both game dialogs slide up from bottom with 350ms easeOutCubic, haptic merge verified wired, and confetti package burst fires from top of level complete dialog.
- Skip Tutorial button on TutorialOverlay, daily challenge card above Play with target tile/board/time, premium ad bypass driven by RemoteConfig threshold
- One-liner:
- Flutter adaptive icons generated for Android (deep-navy background, foreground PNGs all densities) and iOS PrivacyInfo.xcprivacy created with 4 required-reason API declarations wired into Xcode Runner target — prevents ITMS-91053 Apple rejection
- One-liner:
- One-liner:
- SCREENSHOT_GUIDE.md and DATA_SAFETY_GUIDE.md created — complete field-by-field guides for manual iOS/Android screenshot capture and Google Play Data Safety form submission

---

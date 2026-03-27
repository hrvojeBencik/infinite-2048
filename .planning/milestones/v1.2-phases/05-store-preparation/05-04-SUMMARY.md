---
phase: 05-store-preparation
plan: 04
subsystem: store-preparation
tags: [google-play, app-store, screenshots, data-safety, privacy, store-listing]

# Dependency graph
requires:
  - phase: 05-01
    provides: App icon generation and PrivacyInfo.xcprivacy
  - phase: 05-02
    provides: Paywall compliance and RevenueCat integration
  - phase: 05-03
    provides: Store listing metadata (STORE_LISTING.md)
provides:
  - SCREENSHOT_GUIDE.md with exact device sizes and scene descriptions for manual screenshot capture
  - DATA_SAFETY_GUIDE.md with field-by-field Google Play Data Safety form completion guide
  - Human-action checklist for closed testing initiation (14-day gate)
affects:
  - Store submission workflow (both iOS App Store Connect and Google Play Console)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Planning documentation pattern: field-by-field guides for manual store console actions"

key-files:
  created:
    - .planning/phases/05-store-preparation/SCREENSHOT_GUIDE.md
    - .planning/phases/05-store-preparation/DATA_SAFETY_GUIDE.md
  modified: []

key-decisions:
  - "STORE-08 (fastlane) confirmed descoped per D-05 — all screenshot capture and metadata upload is manual via store consoles"
  - "6.7\" iPhone does not have a separate App Store Connect upload slot — auto-scales from 6.9\" set; no separate screenshots needed (per D-07 and RESEARCH.md)"
  - "Google Play Data Safety declarations: Device IDs (AdMob), App interactions (Firebase Analytics), App info/performance (Firebase Crashlytics), Personal info conditional (Firebase Auth optional)"

patterns-established:
  - "Screenshot guide pattern: device size table + scene visual contract + step-by-step capture commands + submission checklist"
  - "Data Safety guide pattern: table-per-data-type with Collected/Shared/Purpose/Encrypted/Deletion fields"

requirements-completed: [STORE-02, STORE-07, STORE-08]

# Metrics
duration: 2min
completed: 2026-03-27
---

# Phase 05 Plan 04: Store Preparation Guides Summary

**SCREENSHOT_GUIDE.md and DATA_SAFETY_GUIDE.md created — complete field-by-field guides for manual iOS/Android screenshot capture and Google Play Data Safety form submission**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-27T07:36:20Z
- **Completed:** 2026-03-27T07:38:10Z
- **Tasks:** 1 auto task (+ 1 advisory checkpoint + 1 human-verify auto-approved)
- **Files modified:** 2

## Accomplishments

- Created SCREENSHOT_GUIDE.md covering all required device sizes: iPhone 6.9" (1260x2736), 6.5" (1284x2778), iPad 13" (2064x2752), Android phone (1080x1920), Android tablets; includes the 6.7" auto-scaling clarification per D-07
- Created DATA_SAFETY_GUIDE.md with field-by-field answers for every Google Play Data Safety section: Device IDs (AdMob), App interactions (Firebase Analytics), App info and performance (Firebase Crashlytics), and conditional Personal info (Firebase Auth)
- Both guides include submission checklists and reference links to official SDK disclosure documentation

## Task Commits

Each task was committed atomically:

1. **Task 0: IMMEDIATE advisory — Start Google Play closed testing 14-day clock** - Advisory checkpoint; no code changes; user action required
2. **Task 1: Create screenshot capture guide and Data Safety form guide** - `786e06a` (docs)
3. **Task 2: Verify store preparation completeness** - Auto-approved (auto_advance: true); human verification steps documented in guide files

**Plan metadata:** (docs commit — see below)

## Files Created/Modified

- `.planning/phases/05-store-preparation/SCREENSHOT_GUIDE.md` — Device sizes, required scenes, capture steps, simulator commands, and submission checklist for iOS App Store Connect and Google Play Console
- `.planning/phases/05-store-preparation/DATA_SAFETY_GUIDE.md` — Field-by-field Google Play Data Safety form guide for AdMob, Firebase Analytics, Firebase Crashlytics, and optional Firebase Auth data declarations

## Decisions Made

- STORE-08 (fastlane) is confirmed descoped per D-05; all store interactions are manual
- 6.7" iPhone screenshots auto-scale from 6.9" set — no separate capture needed
- Data Safety declarations align with SDK disclosure guides from Google (AdMob and Firebase official docs linked)
- Firebase Auth personal info marked as optional (users can play without signing in)

## Deviations from Plan

None — plan executed exactly as written. Advisory checkpoint (Task 0) documented as informational. Human-verify checkpoint (Task 2) auto-approved per `auto_advance: true` config.

## Issues Encountered

None.

## User Setup Required

The following manual actions are required before store submission:

**Google Play — IMMEDIATE:**
1. Start closed testing track with 12+ testers in Google Play Console (14-day clock must start now — this is the longest lead-time item)
2. Complete the Data Safety form following `DATA_SAFETY_GUIDE.md`

**Screenshots (both platforms):**
3. Capture screenshots following `SCREENSHOT_GUIDE.md` for all required device sizes
4. Upload to App Store Connect (iOS) and Google Play Console (Android)

**RevenueCat:**
5. Confirm RevenueCat API keys are set (replace placeholder keys in AppConstants)

**Paywall visual:**
6. Verify paywall screen visually on a device/simulator — annual price must be the largest text element and all 5 required elements visible without scrolling

**Store metadata:**
7. Copy store listing text from `.planning/phases/05-store-preparation/STORE_LISTING.md` into both store consoles

## Next Phase Readiness

Phase 5 is the final phase of the v1.2 milestone. All automated tasks are complete:
- App icon generated
- PrivacyInfo.xcprivacy created
- Paywall compliance implemented
- Store listing metadata created (STORE_LISTING.md)
- Screenshot and Data Safety guides ready for manual action

The 14-day Google Play closed testing gate is the only calendar blocker remaining. All code changes are complete and ready for store submission.

## Self-Check: PASSED

- SCREENSHOT_GUIDE.md exists at `.planning/phases/05-store-preparation/SCREENSHOT_GUIDE.md`: FOUND
- DATA_SAFETY_GUIDE.md exists at `.planning/phases/05-store-preparation/DATA_SAFETY_GUIDE.md`: FOUND
- 05-04-SUMMARY.md exists at `.planning/phases/05-store-preparation/05-04-SUMMARY.md`: FOUND
- Commit 786e06a (task 1): FOUND
- Commit 78c4a61 (final metadata): FOUND

---
*Phase: 05-store-preparation*
*Completed: 2026-03-27*

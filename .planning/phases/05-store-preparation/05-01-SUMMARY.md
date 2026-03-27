---
phase: 05-store-preparation
plan: 01
subsystem: infra
tags: [flutter_launcher_icons, adaptive-icon, ios, privacy-manifest, xcprivacy, store-submission]

# Dependency graph
requires: []
provides:
  - Android adaptive launcher icons with deep-navy (#0A0E21) background, foreground PNGs in all drawable-* densities
  - iOS app icon with alpha channel removed (remove_alpha_ios: true)
  - ios/Runner/PrivacyInfo.xcprivacy with 4 required-reason API declarations (UserDefaults, FileTimestamp, DiskSpace, SystemBootTime)
  - PrivacyInfo.xcprivacy registered in Xcode Runner target (PBXFileReference + PBXBuildFile + PBXGroup + PBXResourcesBuildPhase)
  - Privacy policy URL confirmed live at https://hrvojebencik.github.io/infinite-2048/privacy-policy.html
affects: [05-store-preparation]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - flutter_launcher_icons adaptive icon config with background color + foreground image path
    - iOS PrivacyInfo.xcprivacy pattern for required-reason API declarations

key-files:
  created:
    - ios/Runner/PrivacyInfo.xcprivacy
    - android/app/src/main/res/drawable-hdpi/ic_launcher_foreground.png
    - android/app/src/main/res/drawable-mdpi/ic_launcher_foreground.png
    - android/app/src/main/res/drawable-xhdpi/ic_launcher_foreground.png
    - android/app/src/main/res/drawable-xxhdpi/ic_launcher_foreground.png
    - android/app/src/main/res/drawable-xxxhdpi/ic_launcher_foreground.png
    - android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
    - android/app/src/main/res/values/colors.xml
  modified:
    - pubspec.yaml
    - ios/Runner.xcodeproj/project.pbxproj

key-decisions:
  - "adaptive_icon_background uses #0A0E21 (AppColors.background) — consistent with splash screen and app theme"
  - "NSPrivacyTracking false — no ATT prompt in app, AdMob/Firebase SDKs bundle their own privacy manifests"
  - "flutter_launcher_icons v0.14.x places adaptive icon foreground in drawable-* (not mipmap-*) — correct behavior, plan had wrong path expectations"

patterns-established:
  - "iOS PrivacyInfo.xcprivacy: 4 API declarations with PBXFileReference ID A1B2C3D4E5F60001, PBXBuildFile ID A1B2C3D4E5F60002"

requirements-completed: [STORE-01, STORE-03, STORE-06]

# Metrics
duration: 2min
completed: 2026-03-27
---

# Phase 5 Plan 1: App Icon Config and iOS Privacy Manifest Summary

**Flutter adaptive icons generated for Android (deep-navy background, foreground PNGs all densities) and iOS PrivacyInfo.xcprivacy created with 4 required-reason API declarations wired into Xcode Runner target — prevents ITMS-91053 Apple rejection**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-27T07:20:18Z
- **Completed:** 2026-03-27T07:22:30Z
- **Tasks:** 2
- **Files modified:** 10

## Accomplishments
- Updated pubspec.yaml flutter_launcher_icons config with adaptive_icon_background (#0A0E21), adaptive_icon_foreground, and remove_alpha_ios: true
- Ran `dart run flutter_launcher_icons` — generated foreground PNGs in all drawable-* densities plus mipmap-anydpi-v26/ic_launcher.xml and colors.xml
- Created ios/Runner/PrivacyInfo.xcprivacy with all 4 required-reason API categories (UserDefaults CA92.1, FileTimestamp 3B52.1, DiskSpace 7D9E.1, SystemBootTime 35F9.1)
- Added PrivacyInfo.xcprivacy to Xcode Runner target via 4 project.pbxproj edits (PBXFileReference, PBXBuildFile, PBXGroup children, PBXResourcesBuildPhase)
- Confirmed privacy policy URL live: https://hrvojebencik.github.io/infinite-2048/privacy-policy.html returns HTTP 200

## Task Commits

Each task was committed atomically:

1. **Task 1: Update flutter_launcher_icons config and generate icons** - `c5e1e54` (chore)
2. **Task 2: Create iOS PrivacyInfo.xcprivacy, add to Xcode target, and verify privacy policy URL** - `3adc20b` (feat)

## Files Created/Modified
- `pubspec.yaml` - Added adaptive_icon_background, adaptive_icon_foreground, remove_alpha_ios: true to flutter_launcher_icons section
- `ios/Runner/PrivacyInfo.xcprivacy` - Apple privacy manifest with 4 required-reason API declarations
- `ios/Runner.xcodeproj/project.pbxproj` - Added PBXFileReference, PBXBuildFile, group child, and Resources build phase entry for PrivacyInfo.xcprivacy
- `android/app/src/main/res/drawable-{hdpi,mdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher_foreground.png` - Adaptive icon foreground images
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` - Adaptive icon XML referencing background color and foreground drawable
- `android/app/src/main/res/values/colors.xml` - ic_launcher_background color (#0A0E21)

## Decisions Made
- Used #0A0E21 (AppColors.background) as adaptive_icon_background — matches app splash screen and overall dark theme
- NSPrivacyTracking set to false because no ATT prompt is shown; Firebase/AdMob SDKs bundle their own NSPrivacyCollectedDataTypes declarations
- PrivacyInfo.xcprivacy added programmatically to project.pbxproj rather than via Xcode GUI — avoids checkpoint/manual step

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Corrected foreground PNG path expectation**
- **Found during:** Task 1 (icon generation verification)
- **Issue:** Plan acceptance criteria specified `mipmap-hdpi/ic_launcher_foreground.png` but flutter_launcher_icons v0.14.x places foreground PNGs in `drawable-hdpi/` (not `mipmap-hdpi/`)
- **Fix:** Verified actual generated paths in `drawable-*` directories — this is correct behavior for the tool version; no code change needed
- **Files modified:** None (documentation adjustment only)
- **Verification:** `find android/app/src/main/res -name "ic_launcher_foreground*"` confirmed 5 files in drawable-* dirs
- **Committed in:** c5e1e54 (Task 1 commit)

---

**Total deviations:** 1 (Rule 1 — wrong path expectation in plan, actual output is correct)
**Impact on plan:** No scope creep. Tool behavior was correct; plan had stale path assumption.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- STORE-01 (icon compliance) satisfied: adaptive icons configured and generated
- STORE-03 (privacy policy) satisfied: URL live and returns HTTP 200
- STORE-06 (iOS privacy manifest) satisfied: PrivacyInfo.xcprivacy in Runner target prevents ITMS-91053
- Ready for Plan 02 (store metadata/screenshots) and Plan 03 (Android listing)

---
*Phase: 05-store-preparation*
*Completed: 2026-03-27*

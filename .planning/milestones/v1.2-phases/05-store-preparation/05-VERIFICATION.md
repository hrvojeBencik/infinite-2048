---
phase: 05-store-preparation
verified: 2026-03-26T12:00:00Z
status: human_needed
score: 12/12 must-haves verified
human_verification:
  - test: "Replace RevenueCat placeholder API keys and visually verify paywall screen"
    expected: "AppConstants.revenueCatAppleApiKey and revenueCatGoogleApiKey contain real keys; paywall renders annual price as largest text element (24sp bold) with trial terms, cancel instructions, ToS/Privacy links all visible without scrolling on iPhone SE (375x667)"
    why_human: "Placeholder keys cannot be tested without a real RevenueCat project; visual layout compliance requires simulator or device run"
  - test: "Capture screenshots on all required device sizes and upload to stores"
    expected: "App Store Connect has screenshots for 6.9\" (1260x2736), 6.5\" (1284x2778 or 1242x2688), and iPad 13\" (2064x2752); Google Play has phone (1080x1920) and tablet screenshots — all 3 scenes (gameplay, level select, level complete) covered"
    why_human: "Screenshot capture requires running the app on simulators/physical devices and manual upload to store consoles"
  - test: "Complete Google Play Data Safety form following DATA_SAFETY_GUIDE.md"
    expected: "Data Safety form in Google Play Console declares Device IDs (AdMob), App interactions (Firebase Analytics), App info/performance (Firebase Crashlytics), and conditional Personal info (Firebase Auth) — form saved and verified"
    why_human: "Requires manual action in Google Play Console; cannot be automated"
  - test: "Start Google Play 14-day closed testing clock"
    expected: "Closed testing track is Active in Google Play Console with 12+ testers and an uploaded build; track start date is recorded"
    why_human: "Requires manual action in Google Play Console and an actual build upload"
  - test: "Copy store listing metadata into App Store Connect and Google Play Console"
    expected: "Both store consoles have title, description, keywords/short description, and category entered from STORE_LISTING.md; using 'Puzzle with Levels & Zones' (26 chars) for iOS subtitle — NOT the 31-char version also present in the file"
    why_human: "Requires manual entry in store consoles; the STORE_LISTING.md file contains both a 31-char (over-limit) and a 26-char (correct) subtitle — human must use the correct one"
---

# Phase 5: Store Preparation Verification Report

**Phase Goal:** Both stores have complete, compliant, polished listings and the app is ready for public release submission
**Verified:** 2026-03-26T12:00:00Z
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | App icon is configured with adaptive icon background and foreground for Android | VERIFIED | `pubspec.yaml` contains `adaptive_icon_background: "#0A0E21"` and `adaptive_icon_foreground: "assets/icon/icon.png"`; foreground PNGs exist in all `drawable-*` densities |
| 2 | iOS icon generation includes remove_alpha_ios: true | VERIFIED | `pubspec.yaml` line 58: `remove_alpha_ios: true` |
| 3 | PrivacyInfo.xcprivacy declares UserDefaults, FileTimestamp, DiskSpace, and SystemBootTime APIs | VERIFIED | All 4 `NSPrivacyAccessedAPICategory*` entries confirmed in file; `NSPrivacyTracking` present as `<false/>` |
| 4 | PrivacyInfo.xcprivacy is added to the Runner target in Xcode project | VERIFIED | 4 occurrences of `PrivacyInfo.xcprivacy` in `project.pbxproj` (PBXFileReference, PBXBuildFile, PBXGroup child, PBXResourcesBuildPhase) |
| 5 | Privacy policy URL is live and returns HTTP 200 | VERIFIED | `curl` returns 200 for `https://hrvojebencik.github.io/infinite-2048/privacy-policy.html` |
| 6 | Paywall screen displays full annual price as the most prominent pricing element | VERIFIED | `paywall_page.dart` line 311: `fontSize: 24` applied to `priceString` from `product?.priceString` — largest text on screen |
| 7 | Trial terms, cancel instructions, ToS/Privacy links, and Restore button are all visible without scrolling | VERIFIED (code) / ? UNCERTAIN (visual) | Code: "Cancel anytime" (line 108), `termsOfServiceUrl` (line 364), `privacyPolicyUrl` (line 369), `SubscriptionRestoreRequested` (line 174) all present; visual above-fold layout requires human verification on device |
| 8 | Premium entitlement status is queryable from anywhere in the app via SubscriptionBloc | VERIFIED | `SubscriptionBloc` registered as lazy singleton in `di.dart` and provided globally at app root in `app.dart` `MultiBlocProvider`; initialized with `SubscriptionCheckRequested` |
| 9 | RevenueCat SDK is initialized before any subscription queries | VERIFIED | `_onCheckRequested` and `_onLoadOfferings` both call `await _service.initialize()` before any SDK operations |
| 10 | App Store listing has title, subtitle, keywords, full description, and category | VERIFIED | `STORE_LISTING.md` contains title "2048: Merge Quest", subtitle "Puzzle with Levels & Zones" (26 chars), keywords 68 chars, category "Games > Puzzle", description ~1,850 chars |
| 11 | Play Store listing has title, short description, full description, and category | VERIFIED | `STORE_LISTING.md` contains title "2048: Merge Quest", short description 60 chars, category "Game > Puzzle", full description ~1,950 chars |
| 12 | Version bumped from 1.0.0+1 to 1.0.0+2 | VERIFIED | `pubspec.yaml` line 4: `version: 1.0.0+2` |

**Score:** 12/12 truths verified (automated); 5 items require human action before submission is possible

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `pubspec.yaml` | Complete flutter_launcher_icons config with adaptive icon fields | VERIFIED | Contains `adaptive_icon_background`, `adaptive_icon_foreground`, `remove_alpha_ios: true`, `image_path: "assets/icon/icon.png"`, `version: 1.0.0+2` |
| `ios/Runner/PrivacyInfo.xcprivacy` | Apple privacy manifest with required API declarations | VERIFIED | 4 API categories declared; `NSPrivacyTracking: <false/>` |
| `ios/Runner.xcodeproj/project.pbxproj` | Xcode project with PrivacyInfo.xcprivacy in Runner target | VERIFIED | 4 occurrences of `PrivacyInfo.xcprivacy` confirming full Xcode target wiring |
| `android/app/src/main/res/drawable-hdpi/ic_launcher_foreground.png` | Adaptive icon foreground at hdpi | VERIFIED | File exists |
| `android/app/src/main/res/drawable-xxxhdpi/ic_launcher_foreground.png` | Adaptive icon foreground at xxxhdpi | VERIFIED | File exists |
| `lib/features/subscription/data/services/subscription_service.dart` | RevenueCat SDK wrapper service (61 lines) | VERIFIED | 61 lines; contains `initialize()`, `getOfferings()`, `purchasePackage()`, `restorePurchases()`, `isPremium()` |
| `lib/features/subscription/presentation/bloc/subscription_bloc.dart` | BLoC managing subscription state (90 lines) | VERIFIED | 90 lines; `await _service.initialize()` in both `_onCheckRequested` and `_onLoadOfferings` |
| `lib/features/subscription/presentation/bloc/subscription_event.dart` | Sealed class events | VERIFIED | `sealed class SubscriptionEvent` with 4 final classes |
| `lib/features/subscription/presentation/bloc/subscription_state.dart` | Sealed class states | VERIFIED | `sealed class SubscriptionState` with 5 final state classes |
| `lib/features/subscription/presentation/pages/paywall_page.dart` | Apple 3.1.2 compliant paywall (402 lines) | VERIFIED | 402 lines; uses `BlocConsumer`; extracts `_PaywallHeader`, `_FeatureList`, `_PricingCard`, `_LegalLinksRow`; `priceString` at `fontSize: 24`; all compliance elements present |
| `lib/core/constants/app_constants.dart` | RevenueCat API key constants | VERIFIED (with known stub) | Contains `revenueCatAppleApiKey`, `revenueCatGoogleApiKey`, `premiumEntitlementId = 'premium'`; keys are intentional placeholders documented as requiring operator replacement |
| `.planning/phases/05-store-preparation/STORE_LISTING.md` | ASO-optimized store listings for both platforms | VERIFIED | Contains complete iOS and Play Store metadata; note: subtitle section shows both the 31-char (over-limit) version and the corrected 26-char version — user must use the 26-char version |
| `.planning/phases/05-store-preparation/SCREENSHOT_GUIDE.md` | Device sizes, scenes, and capture instructions | VERIFIED | Contains 1260x2736 (6.9"), 2064x2752 (iPad), 1080x1920 (Android); 6.7" auto-scale note present; 3 scenes documented |
| `.planning/phases/05-store-preparation/DATA_SAFETY_GUIDE.md` | Google Play Data Safety form guide | VERIFIED | Contains "Device or other IDs", "App interactions", "App info and performance"; privacy policy URL present |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `pubspec.yaml` | `assets/icon/icon.png` | `image_path` and `adaptive_icon_foreground` | WIRED | Both fields reference `assets/icon/icon.png` |
| `project.pbxproj` | `PrivacyInfo.xcprivacy` | PBXFileReference, PBXBuildFile, PBXGroup, PBXResourcesBuildPhase | WIRED | 4 occurrences confirm all 4 required Xcode project entries |
| `paywall_page.dart` | `subscription_bloc.dart` | `BlocConsumer<SubscriptionBloc, SubscriptionState>` | WIRED | `BlocConsumer` wraps entire body; dispatches `SubscriptionLoadOfferings`, `SubscriptionPurchaseRequested`, `SubscriptionRestoreRequested` |
| `subscription_bloc.dart` | `subscription_service.dart` | `SubscriptionService` method calls including `initialize()` | WIRED | `_service.initialize()`, `_service.getOfferings()`, `_service.isPremium()`, `_service.purchasePackage()`, `_service.restorePurchases()` all called |
| `di.dart` | `subscription_service.dart` | `registerLazySingleton<SubscriptionService>` | WIRED | Line 47: `sl.registerLazySingleton<SubscriptionService>(() => SubscriptionService())` |
| `app.dart` | `subscription_bloc.dart` | `BlocProvider<SubscriptionBloc>` in `MultiBlocProvider` | WIRED | Line 30-32: `BlocProvider<SubscriptionBloc>` with `SubscriptionCheckRequested` initialization |
| `router.dart` | `paywall_page.dart` | `GoRoute(path: '/paywall')` | WIRED | Line 291: `path: '/paywall'` confirmed |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|-------------------|--------|
| `paywall_page.dart` | `currentPackage` / `priceString` | `state.offerings?.current?.availablePackages.firstOrNull` from `BlocConsumer` state | RevenueCat SDK `getOfferings()` populates via `SubscriptionService` — real data when RevenueCat project is configured | FLOWING (when keys replaced) |
| `paywall_page.dart` | `state.isPremium` | `SubscriptionLoaded.isPremium` from `_service.isPremium()` → `Purchases.getCustomerInfo()` | Real SDK call to RevenueCat; `false` when SDK is uninitialized or no active entitlement | FLOWING (fallback to false on uninitialized) |

Note: Data flow is structurally correct and will produce real data once RevenueCat API keys are replaced with real credentials. The current `appl_PLACEHOLDER_REPLACE_ME` keys will cause SDK initialization to fail silently (logged only), rendering the paywall with loading state and no package data. This is an intentional known stub documented in 05-02-SUMMARY.md.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| `flutter analyze` passes with no errors | `flutter analyze` | `No issues found! (ran in 1.0s)` | PASS |
| `pubspec.yaml` has adaptive icon config | `grep "adaptive_icon_background" pubspec.yaml` | `adaptive_icon_background: "#0A0E21"` | PASS |
| `PrivacyInfo.xcprivacy` exists with 4 API declarations | `grep -c "NSPrivacyAccessedAPICategoryUser..." ...` | 4 | PASS |
| `PrivacyInfo.xcprivacy` referenced in `project.pbxproj` | `grep -c "PrivacyInfo.xcprivacy" project.pbxproj` | 4 | PASS |
| Privacy policy URL accessible | `curl -s -o /dev/null -w "%{http_code}" "https://..."` | 200 | PASS |
| Version bumped to 1.0.0+2 | `grep "version:" pubspec.yaml` | `version: 1.0.0+2` | PASS |
| Paywall shows price at 24sp bold | `grep "fontSize: 24" paywall_page.dart` | Found on line 311 adjacent to `priceString` | PASS |
| Paywall has cancel instructions | `grep "Cancel anytime" paywall_page.dart` | Found on line 108 | PASS |
| `/paywall` route registered | `grep "path: '/paywall'" router.dart` | Found on line 291 | PASS |
| SubscriptionBloc provided globally | `grep "BlocProvider.*SubscriptionBloc" app.dart` | Found on line 30 | PASS |
| Paywall visual compliance (above-fold) | Requires running app on simulator | Not testable without device | SKIP |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| STORE-01 | 05-01 | App icon at 1024x1024 (no alpha for iOS), adaptive icon for Android | SATISFIED | `remove_alpha_ios: true` in pubspec; adaptive foreground PNGs in all `drawable-*` densities |
| STORE-02 | 05-04 | Store screenshots generated for all required device sizes | NEEDS HUMAN | `SCREENSHOT_GUIDE.md` provides exact dimensions and scenes; actual screenshot capture and upload is a manual human action |
| STORE-03 | 05-01 | Privacy policy URL live and accessible | SATISFIED | HTTP 200 confirmed at `https://hrvojebencik.github.io/infinite-2048/privacy-policy.html` |
| STORE-04 | 05-03 | App Store metadata complete (title, subtitle, keywords, description, categories) | SATISFIED | All fields present in `STORE_LISTING.md`; must be copied into App Store Connect manually |
| STORE-05 | 05-03 | Play Store metadata complete (title, short description, full description, categories) | SATISFIED | All fields present in `STORE_LISTING.md`; must be copied into Play Console manually |
| STORE-06 | 05-01 | iOS PrivacyInfo.xcprivacy manifest configured | SATISFIED | File exists with all 4 required API declarations; wired into Xcode Runner target |
| STORE-07 | 05-04 | Google Play Data Safety form completed | NEEDS HUMAN | `DATA_SAFETY_GUIDE.md` provides field-by-field answers; actual form submission is a manual human action in Play Console |
| STORE-08 | 05-04 | Fastlane pipeline automates screenshot capture and framing | DESCOPED | Confirmed descoped per D-05 in all plans; no fastlane implementation; all store actions are manual. REQUIREMENTS.md marks this as complete (checkbox checked) |
| STORE-09 | 05-03 | ASO-optimized store copy for both platforms | SATISFIED | `STORE_LISTING.md` has keyword strategy, 68-char iOS keywords, SEO-dense Play Store description |
| STORE-10 | 05-02 | RevenueCat paywall compliant with Apple 3.1.2 | SATISFIED (code) / NEEDS HUMAN (visual + keys) | Code: all required elements present and wired; API keys are placeholders requiring operator replacement; visual above-fold compliance needs human verification on device |

**Orphaned requirements:** None. All 10 STORE-* requirements from REQUIREMENTS.md are covered by plans 05-01 through 05-04.

### Anti-Patterns Found

| File | Content | Severity | Impact |
|------|---------|----------|--------|
| `lib/core/constants/app_constants.dart:42-43` | `revenueCatAppleApiKey = 'appl_PLACEHOLDER_REPLACE_ME'` and `revenueCatGoogleApiKey = 'goog_PLACEHOLDER_REPLACE_ME'` | WARNING (intentional stub) | App will fail to initialize RevenueCat SDK at runtime; paywall will show loading state with no purchasable package; subscription purchase is blocked until real keys are configured. Documented as intentional in 05-02-SUMMARY.md |
| `.planning/phases/05-store-preparation/STORE_LISTING.md:17-26` | iOS subtitle section contains BOTH "Puzzle Game with Levels & Zones" (31 chars, over-limit) AND "Puzzle with Levels & Zones" (26 chars, correct) | INFO | Could cause confusion during store console entry. User must use the 26-char version. The document labels the 31-char as "trimmed version below" which is clear, but the over-limit string should not be blindly copy-pasted |

### Human Verification Required

**1. Replace RevenueCat API Keys**

**Test:** Replace `AppConstants.revenueCatAppleApiKey` (`'appl_PLACEHOLDER_REPLACE_ME'`) and `AppConstants.revenueCatGoogleApiKey` (`'goog_PLACEHOLDER_REPLACE_ME'`) in `lib/core/constants/app_constants.dart` with real public API keys from the RevenueCat dashboard.
**Expected:** SDK initializes successfully on both platforms; `getOfferings()` returns real subscription packages; paywall displays actual price and trial terms.
**Why human:** RevenueCat project creation and API key retrieval requires user account access at https://app.revenuecat.com/

**2. Verify Paywall Visual Compliance (Apple Guideline 3.1.2)**

**Test:** Run app on iPhone SE simulator (`flutter run -d "iPhone SE (3rd generation)"`), navigate to paywall via `/paywall` route, verify visually without scrolling.
**Expected:** Annual price (24sp bold white) is the largest text element on screen; trial terms ("Try free for 7 days, then X/year") are visible; "Cancel anytime in your App Store settings" is visible; Terms of Service and Privacy Policy links are tappable with 44dp touch targets; Restore Purchases button is present — all above the fold on a 375x667 screen.
**Why human:** Above-fold layout compliance depends on runtime rendering, font metrics, and device pixel density — cannot be verified statically.

**3. Capture and Upload Store Screenshots**

**Test:** Follow `SCREENSHOT_GUIDE.md` to capture screenshots on all required simulators and upload to store consoles.
**Expected:** App Store Connect has screenshots for iPhone 6.9" (1260x2736), iPhone 6.5" (1284x2778), iPad 13" (2064x2752); Google Play Console has phone (1080x1920) and at least one tablet size. All 3 scenes (active gameplay, level select, level complete with confetti + share button) captured for each size.
**Why human:** Screenshot capture and console upload requires running app on multiple simulators and manual GUI action in Apple/Google store consoles.

**4. Complete Google Play Data Safety Form**

**Test:** Follow `DATA_SAFETY_GUIDE.md` in Google Play Console → App content → Data Safety.
**Expected:** Form correctly declares Device or other IDs (AdMob), App interactions (Firebase Analytics), App info and performance (Firebase Crashlytics), and optional Personal info (Firebase Auth sign-in). Form is saved and shows "Completed" status.
**Why human:** Requires Google Play Console access and manual form submission.

**5. Start Google Play 14-Day Closed Testing Clock**

**Test:** Create closed testing track in Google Play Console with 12+ testers and upload any build (debug build is sufficient to start the clock).
**Expected:** Closed testing track status shows "Active"; 14-day clock starts from track activation date; production access unlocks after 14 days.
**Why human:** Requires Google Play Console access, a compiled build (AAB), and manually adding tester email addresses. This is the longest-lead-time item — it must be started immediately.

**6. Enter Store Listing Text into Store Consoles**

**Test:** Copy metadata from `STORE_LISTING.md` into App Store Connect and Google Play Console.
**Expected:** Both consoles have complete metadata entered. For iOS, use the subtitle "Puzzle with Levels & Zones" (26 chars) — NOT "Puzzle Game with Levels & Zones" (31 chars, over-limit) which also appears in the file.
**Why human:** Store console metadata entry requires account access and manual GUI input.

### Gaps Summary

No automated gaps found. All 12 must-haves from the four plan files are verified in the codebase. The phase goal "Both stores have complete, compliant, polished listings and the app is ready for public release submission" is substantially achieved in code and configuration.

The only items remaining are:
1. **One intentional stub** — RevenueCat API keys are placeholders that must be replaced before submission (this is by design and documented)
2. **Five human actions** — All require store console access (screenshot capture/upload, Data Safety form, closed testing track, metadata entry) that cannot be automated or verified programmatically
3. **One documentation note** — STORE_LISTING.md contains a 31-char subtitle (over App Store limit) alongside the correct 26-char version; user must use the 26-char version

All code is clean (`flutter analyze` passes with no issues), all architectural patterns follow CLAUDE.md conventions (BLoC sealed classes, clean architecture, GetIt DI), and all wiring is confirmed end-to-end.

---

_Verified: 2026-03-26T12:00:00Z_
_Verifier: Claude (gsd-verifier)_

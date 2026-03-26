# Phase 5: Store Preparation - Research

**Researched:** 2026-03-26
**Domain:** Mobile app store publishing (Apple App Store + Google Play) — Flutter
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**App Icon (STORE-01)**
- D-01: User will provide a custom source icon PNG. Use `flutter_launcher_icons` to generate all sizes from single source.
- D-02: Android adaptive icon uses solid brand color background (hex TBD — user to specify, or Claude picks from AppColors).
- D-03: iOS icon must have no alpha — `flutter_launcher_icons` handles via `remove_alpha_ios: true`.

**Screenshots (STORE-02)**
- D-04: Screenshots captured manually on simulators/devices — no fastlane automation.
- D-05: STORE-08 (fastlane pipeline) is DESCOPED. Screenshots and metadata uploaded directly through App Store Connect and Google Play Console.
- D-06: Screenshot scenes: gameplay (active board with tiles), level select/zones, and level complete/achievements. Three key screens minimum per platform.
- D-07: Required device sizes: iPhone 6.9", 6.7" (note: 6.7" is optional — see research), iPad 13" for iOS; phone + 7" tablet + 10" tablet for Android.

**Store Listing Copy (STORE-04, STORE-05, STORE-09)**
- D-08: App name: "2048: Merge Quest"
- D-09: Tone: casual and fun, playful, emoji-friendly, appeals to casual puzzle gamers.
- D-10: Category: Games > Puzzle on both platforms.
- D-11: Use `/aso-expert` skill to generate fully optimized store listings.

**Privacy & Compliance (STORE-03, STORE-06, STORE-07)**
- D-12: Privacy policy URL already live at `https://hrvojebencik.github.io/infinite-2048/privacy-policy.html` — verified accessible (HTTP 200).
- D-13: App collects no extra user data beyond Firebase Analytics (usage data) and AdMob (advertising ID). Firebase Auth optional.
- D-14: No custom identifiers or email collection beyond what Firebase Auth provides.

**Paywall Compliance (STORE-10)**
- D-15: Custom Flutter paywall screen exists — needs audit against Apple Guideline 3.1.2.
- D-16: Audit existing paywall widget, identify compliance gaps, fix before submission.

**Google Play Closed Testing (STORE-02 gate)**
- D-17: Personal Google Play Developer account — 14-day closed testing gate applies (post-Nov 2023 policy).
- D-18: Closed testing track must go live with 12+ testers on day 1 of phase execution.

### Claude's Discretion
- Adaptive icon background color selection (from existing AppColors)
- PrivacyInfo.xcprivacy exact API declarations based on dependency audit
- Data Safety form field mapping based on SDK analysis
- Screenshot device frame or caption styling (if any post-processing desired)
- Paywall UI fixes — implementation approach for compliance gaps

### Deferred Ideas (OUT OF SCOPE)
- STORE-08 (Fastlane pipeline): Descoped. Manual screenshot capture and direct store upload for v1 launch.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| STORE-01 | App icon at 1024x1024 (no alpha for iOS), adaptive icon for Android | flutter_launcher_icons config pattern documented; current icon confirmed 1024x1024 RGB; adaptive config gap identified |
| STORE-02 | Store screenshots for all required device sizes | Official Apple and Google screenshot dimensions researched and documented |
| STORE-03 | Privacy policy URL live and accessible | Confirmed HTTP 200 at known URL |
| STORE-04 | App Store metadata complete (title, subtitle, keywords, description, categories) | ASO patterns documented; `/aso-expert` skill invocation is the execution path |
| STORE-05 | Play Store metadata complete (title, short description, full description, categories) | Same as STORE-04 via `/aso-expert` |
| STORE-06 | iOS PrivacyInfo.xcprivacy manifest configured | Required API types and reason codes documented; template provided |
| STORE-07 | Google Play Data Safety form completed | AdMob and Firebase data declarations documented |
| STORE-08 | DESCOPED — not planned | User decision D-05 |
| STORE-09 | ASO-optimized store copy for both platforms | Covered by `/aso-expert` invocation per D-11 |
| STORE-10 | RevenueCat paywall compliant with Apple 3.1.2 | Critical finding: no paywall widget or purchases_flutter dependency exists in codebase — STORE-10 requires building the paywall, not just auditing it |
</phase_requirements>

---

## Summary

Phase 5 prepares both App Store and Google Play listings for first public release. The work splits into five streams: (1) icon generation, (2) screenshot capture, (3) store metadata copy via ASO, (4) privacy compliance (PrivacyInfo.xcprivacy + Data Safety form), and (5) paywall compliance (Apple Guideline 3.1.2).

**Critical finding on STORE-10:** The CONTEXT.md assumes a paywall widget exists to audit. Codebase investigation reveals no paywall widget, no `purchases_flutter` dependency in `pubspec.yaml`, and no subscription feature directory. The analytics service has paywall event stubs (`logPaywallOpened`, `logPurchaseStarted`) but no implementation. The `AdService.onLevelCompleted(isPremium: bool)` signature suggests premium gating was intended but never built. STORE-10 requires **building** a compliant paywall screen from scratch, not just auditing one.

**Icon status:** The existing `assets/icon/icon.png` is confirmed 1024x1024 RGB (no alpha) — suitable as-is for iOS. The `flutter_launcher_icons` config in `pubspec.yaml` lacks `adaptive_icon_background` and `adaptive_icon_foreground` — Android adaptive icon is NOT currently configured. The user must either provide a separate foreground asset or both layers need to be set up.

**Google Play gate:** The 14-day closed testing clock must start on day 1 of phase execution. This is a calendar blocker — not a code task — and blocks production submission regardless of technical readiness.

**Primary recommendation:** Execute phase in dependency order: (1) icon config first (unlocks builds), (2) paywall build (most complex code task), (3) privacy docs, (4) screenshots (needs working builds), (5) ASO copy generation, (6) Google Play upload + start 14-day clock immediately.

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_launcher_icons | 0.14.4 (already in pubspec) | Generate iOS + Android icons from single source | Official Flutter community tool; handles all sizes, alpha removal, adaptive icons |
| purchases_flutter | ^8.x | RevenueCat SDK for IAP subscriptions | Required for STORE-10 paywall — NOT yet in project |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| google_mobile_ads | 7.0.0 (existing) | AdMob integration | Already in project; its data types affect PrivacyInfo and Data Safety form |
| firebase_analytics | 12.0.2 (existing) | Analytics | Already in project; affects Data Safety form |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| flutter_launcher_icons | icons_launcher | icons_launcher has more features but flutter_launcher_icons is already installed and configured |
| purchases_flutter | Manual StoreKit/BillingClient | Never hand-roll IAP — platform edge cases are deeply complex |

**Installation (new dependency for STORE-10 paywall):**
```bash
flutter pub add purchases_flutter
flutter pub get
```

**Version verification:**
```bash
# At research time:
# purchases_flutter: latest stable is ^8.x (verify before coding)
curl -s "https://pub.dev/api/packages/purchases_flutter" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('latest',{}).get('version'))"
```

---

## Architecture Patterns

### App Icon Generation

**Current state:**
```yaml
# pubspec.yaml — existing (incomplete for adaptive)
flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/icon/icon.png"
  # MISSING: adaptive_icon_background, adaptive_icon_foreground, remove_alpha_ios
```

**Required configuration (add to pubspec.yaml):**
```yaml
flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/icon/icon.png"
  remove_alpha_ios: true
  background_color_ios: "#0A0E21"   # AppColors.background
  adaptive_icon_background: "#0A0E21"     # AppColors.background — deep navy
  adaptive_icon_foreground: "assets/icon/icon.png"  # Use same icon as foreground
  # Note: adaptive icon foreground should ideally be a separate asset with
  # transparent background showing only the icon mark. Using full icon.png
  # works but the image will fill the full adaptive layer including safe zone.
```

**Recommended adaptive icon background color:** `#0A0E21` (AppColors.background — the deep navy used throughout the app). This matches the splash screen color and gives visual consistency.

**Command to run:**
```bash
dart run flutter_launcher_icons
```

**Important constraint:** `adaptive_icon_background` and `adaptive_icon_foreground` must BOTH be specified for adaptive icons to generate. If only `image_path` is set, Android generates legacy icons only (not adaptive). The current config produces legacy Android icons only.

### Screenshot Requirements

**iOS — official Apple App Store Connect requirements (verified via official docs):**

| Size Label | Dimensions (Portrait) | Required? |
|------------|----------------------|-----------|
| 6.9" display | 1260 x 2736 px | REQUIRED (unless 6.5" provided) |
| 6.5" display | 1284 x 2778 px or 1242 x 2688 px | Required if 6.9" not provided |
| 6.7" display | No separate slot exists | Auto-scaled from 6.9" |
| 6.3" display | 1179 x 2556 px or 1206 x 2622 px | Optional (auto-scaled from 6.5") |
| iPad 13" | 2064 x 2752 px | REQUIRED if app supports iPad |

**Practical minimum for iOS:** 6.9" portrait + iPad 13" portrait = 2 screenshot sets. 6.7" from CONTEXT.md D-07 does NOT have its own slot — it's covered by the 6.9" set.

**Google Play — required dimensions:**

| Device | Minimum Dimensions | Recommended | Aspect Ratio |
|--------|-------------------|-------------|--------------|
| Phone | 1080 x 1920 px portrait | 1080 x 1920 px | 9:16 |
| 7" tablet | 1200 x 1920 px portrait | 1600 x 2560 px | — |
| 10" tablet | 1600 x 2560 px portrait | 2048 x 2732 px | — |

**Minimum 2 screenshots required for phone; 1 for each tablet size if submitted.**

**Screenshot scenes per D-06:**
1. Active gameplay board with tiles (show tile variety, game in progress)
2. Level/zone selection screen (shows progression depth)
3. Level complete or achievements screen (shows reward loop)

### PrivacyInfo.xcprivacy

**File location:** `ios/Runner/PrivacyInfo.xcprivacy` (does not yet exist)

**Why needed:** Apple requires this file for all App Store submissions since May 1, 2024. It declares required-reason API usage.

**APIs commonly triggered by Flutter + Firebase + AdMob stack:**

| API Category | String | Reason Code | Triggered By |
|---|---|---|---|
| UserDefaults | `NSPrivacyAccessedAPICategoryUserDefaults` | `CA92.1` | Flutter engine, Hive, Firebase |
| File Timestamp | `NSPrivacyAccessedAPICategoryFileTimestamp` | `3B52.1` | Flutter file I/O, Hive |
| Disk Space | `NSPrivacyAccessedAPICategoryDiskSpace` | `7D9E.1` | Firebase Analytics (fixed in v10.24.0+) |
| System Boot Time | `NSPrivacyAccessedAPICategorySystemBootTime` | `35F9.1` | Flutter engine internals |

**Important:** Firebase iOS SDK v10.24.0+ includes its own PrivacyInfo.xcprivacy (bundled as a CocoaPod resource). The app's `PrivacyInfo.xcprivacy` covers app-level declarations. Flutter engine also generates its own. The app-level file acts as a superset declaration.

**Template for `ios/Runner/PrivacyInfo.xcprivacy`:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSPrivacyAccessedAPITypes</key>
  <array>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array>
        <string>CA92.1</string>
      </array>
    </dict>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array>
        <string>3B52.1</string>
      </array>
    </dict>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryDiskSpace</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array>
        <string>7D9E.1</string>
      </array>
    </dict>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategorySystemBootTime</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array>
        <string>35F9.1</string>
      </array>
    </dict>
  </array>
  <key>NSPrivacyCollectedDataTypes</key>
  <array/>
  <key>NSPrivacyTracking</key>
  <false/>
  <key>NSPrivacyTrackingDomains</key>
  <array/>
</dict>
</plist>
```

**Note:** `NSPrivacyTracking: false` is correct since this app uses AdMob but the ATT framework prompt status (opt-in/opt-out) determines tracking. If AdMob is used without ATT prompt, set to `false`. If you implement ATT prompt + personalized ads, consult AdMob's privacy manifest guidance separately.

**Verification:** After adding to ios/Runner/, run `xcodebuild` or open in Xcode to confirm it parses correctly. App Store Connect will validate during upload.

### Google Play Data Safety Form

**What to declare for this app's stack:**

| Data Type | Collected? | Shared? | Required? | Why |
|-----------|-----------|---------|-----------|-----|
| Device or other IDs | Yes | Yes (AdMob) | Yes | Google Mobile Ads SDK collects advertising ID |
| App interactions | Yes | Yes (Firebase) | Yes | Firebase Analytics tracks in-app events |
| App info and performance | Yes | Yes (Firebase Crashlytics) | Yes | Crashlytics collects crash data |
| Personal info (name/email) | Conditional | No | Conditional | Only if user signs in via Firebase Auth (Google/Apple) |

**Key guidance:**
- AdMob data is encrypted in transit (TLS) — Google's guidance is this is still declarable but some developers treat it as out-of-scope. To be safe: declare Device IDs shared with AdMob for advertising purposes.
- Firebase Analytics: declare App interactions and App performance data (usage analytics).
- Firebase Crashlytics: declare App info and performance (crash logs).
- All data should be marked as encrypted in transit.
- User can opt out: no (Firebase analytics collection can be disabled but users cannot self-opt-out within the app).

**Official reference links for each SDK:**
- AdMob: https://developers.google.com/admob/android/privacy/play-data-disclosure
- Firebase: https://firebase.google.com/docs/android/play-data-disclosure

### Paywall Compliance (STORE-10)

**Critical finding:** No paywall implementation exists. `purchases_flutter` is not in pubspec.yaml. No subscription feature directory exists. The CONTEXT.md's D-15/D-16 (audit an existing paywall) is based on an incorrect assumption.

**What actually exists:**
- `AdService.onLevelCompleted(isPremium: bool)` — isPremium flag parameter exists but always resolves to false (no premium check implemented)
- `TileTheme.isPremium` field exists but `_isThemeUnlocked()` returns `true` for all isPremium themes (line 37: `if (theme.isPremium) return true`)
- `AnalyticsService` has paywall event stubs but no actual paywall screen exists

**What needs to be built for Apple Guideline 3.1.2 compliance:**

Apple's subscription paywall must display in the purchase flow:
1. **Subscription name and duration** (e.g., "Merge Quest Premium — Annual")
2. **Full renewal price** — the annual billing amount must be the MOST PROMINENT pricing element
3. **Free trial duration** (if offered) — "7-day free trial, then $X.XX/year"
4. **What the user gets** — features included in the subscription
5. **Sign-in / restore purchases** option for existing subscribers
6. **Terms of Use and Privacy Policy links**

**Key constraint from Apple docs:** "The amount that will be billed must be the most prominent pricing element in the layout." If showing a monthly equivalent, the full annual price must be displayed larger/more prominently.

**Practical approach given no existing implementation:**
- Add `purchases_flutter` dependency (RevenueCat SDK)
- Create `lib/features/subscription/` feature directory following project's clean architecture pattern
- Build `PaywallPage` — a full-screen modal bottom sheet or page
- RevenueCat handles the actual purchase flow; the Flutter widget just presents the UI
- No RevenueCat backend config change needed (pricing/products configured in App Store Connect / Play Console)

**RevenueCat Flutter pattern:**
```dart
// Fetch offerings
final offerings = await Purchases.getOfferings();
final offering = offerings.current;
final package = offering?.annual; // or monthly

// Display: package.storeProduct.priceString (shows full annual price)
// Display: package.storeProduct.introductoryPrice?.price for trial

// Purchase
await Purchases.purchasePackage(package!);
```

**What the paywall screen must show (compliant layout):**
```
[App branding / feature list]

Premium - Annual Subscription
$XX.XX/year                    ← MOST PROMINENT (large font)
(equivalent to $X.XX/month)   ← smaller/subordinate

7-day free trial, then $XX.XX/year

[Subscribe Button]
[Restore Purchases link]
[Terms of Use] · [Privacy Policy]
```

### Version Bump

`pubspec.yaml` currently at `version: 1.0.0+1`. Should be bumped to `1.0.0+2` (or `1.0.1+2` for marketing) before store submission. Build number (versionCode for Android, CFBundleVersion for iOS) must be a positive integer greater than any previously submitted build.

**Pattern (Flutter):**
```yaml
version: 1.0.0+2  # format: marketing_version+build_number
```

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| In-app purchases | Custom StoreKit/BillingClient integration | `purchases_flutter` (RevenueCat) | Platform IAP has 50+ edge cases: receipt validation, subscription state sync, restore purchases, promo codes, family sharing, grace periods, billing retry. RevenueCat handles all of these. |
| Icon generation | Manual Photoshop resize scripts | `flutter_launcher_icons` | Already installed; handles all required sizes for both platforms including adaptive icon layers |
| Adaptive icon background | Image editor work | Config hex color in pubspec.yaml | `adaptive_icon_background: "#0A0E21"` generates all required background assets automatically |
| Privacy manifest | Writing from memory | Xcode's Privacy Report tool | Xcode can scan your binary and list all required-reason APIs detected — use this to validate the template |

**Key insight:** The paywall is the most risk-prone item. RevenueCat's SDK surface area (Purchases.configure, getOfferings, purchasePackage, restorePurchases) is small and well-documented. Never manage subscription state in local storage — always query RevenueCat's CustomerInfo for current entitlement status.

---

## Common Pitfalls

### Pitfall 1: Adaptive Icon Without Foreground Asset
**What goes wrong:** Setting only `adaptive_icon_background` without `adaptive_icon_foreground` causes `flutter_launcher_icons` to silently skip adaptive icon generation. Android gets legacy icons only.
**Why it happens:** Both fields are required — neither is optional.
**How to avoid:** Set both `adaptive_icon_background` AND `adaptive_icon_foreground` in pubspec.yaml.
**Warning signs:** No `mipmap-*/ic_launcher_foreground.png` files generated in `android/app/src/main/res/`.

### Pitfall 2: Screenshot 6.7" Does Not Exist in App Store Connect
**What goes wrong:** D-07 lists "6.7"" as a required size but App Store Connect has no 6.7" slot. The 6.9" set covers all large iPhones.
**Why it happens:** Apple consolidates display sizes — 6.9" screenshots are auto-scaled for 6.7" and 6.3" devices.
**How to avoid:** Only upload 6.9" and 6.5"/iPad 13". Do not look for a 6.7" upload slot — it doesn't exist.
**Warning signs:** Confusion when the App Store Connect UI doesn't show expected device size options.

### Pitfall 3: PrivacyInfo.xcprivacy Not in Xcode Target
**What goes wrong:** The file exists in the filesystem but isn't added to the Xcode Runner target — App Store Connect still reports ITMS-91053 missing API declaration errors.
**Why it happens:** Flutter projects often need files to be explicitly added to the Xcode project target membership.
**How to avoid:** After creating `ios/Runner/PrivacyInfo.xcprivacy`, open `ios/Runner.xcworkspace` in Xcode and verify the file appears in the Runner target's file list. If not, drag it in and check "Runner" target membership.
**Warning signs:** File exists locally but Xcode's build log doesn't reference it.

### Pitfall 4: Google Play Closed Testing 14-Day Gate
**What goes wrong:** Team waits until screenshots/metadata are polished before uploading to closed testing — then realizes the 14-day clock hasn't started.
**Why it happens:** Assumption that closed testing is just pre-production QA, not a calendar gate.
**How to avoid:** Upload ANY working build (even day-1) to the closed testing track the moment the phase starts. The clock runs on calendar time, not test quality.
**Warning signs:** Reaching end of phase with all technical work done but still blocked from production submission because the 14-day period hasn't elapsed.

### Pitfall 5: Paywall Pricing Hierarchy Violation
**What goes wrong:** Showing "Only $X.XX/month" prominently with the annual total in small print — Apple rejects as Guideline 3.1.2 violation.
**Why it happens:** Monthly equivalent feels more conversion-friendly so designers make it the hero price.
**How to avoid:** The ANNUAL total must be the largest/most prominent number. Monthly equivalent can be shown smaller below it.
**Warning signs:** Apple review rejection citing Guideline 3.1.2(a) or 3.1.2(c).

### Pitfall 6: purchases_flutter Not Configured Before Archive
**What goes wrong:** `Purchases.configure(PurchasesConfiguration(apiKey))` not called before making purchase calls — silent failures or crashes.
**Why it happens:** RevenueCat requires initialization with the API key (from RevenueCat dashboard, not hardcoded — use RemoteConfigService or AppConstants).
**How to avoid:** Call `Purchases.configure()` in `main.dart` or `di.dart` alongside other service initializations.
**Warning signs:** `Purchases.getOfferings()` throws "SDK not configured" exception.

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Manual icon resizing to all sizes | flutter_launcher_icons package | 2019+ | Single source PNG → all platform sizes automatically |
| 6.7" and 6.5" separate iOS screenshot slots | 6.9" covers all large iPhones | 2024 | Fewer screenshot sets to maintain |
| Privacy practices in App Store description only | PrivacyInfo.xcprivacy required in binary | May 1, 2024 | Must be in Xcode target or builds rejected |
| Google Play: no testing gate for personal accounts | 12 testers x 14 days required (reduced from 20 in Dec 2024) | Nov 2023 / Dec 2024 | Calendar gate blocks production submission |
| Manual IAP receipt validation | RevenueCat SDK manages subscription state | 2020+ | Never hand-roll subscription management |

**Deprecated/outdated:**
- 6.7" iPhone screenshot slot: Does not exist. Use 6.9" set.
- `purchases_flutter` < 5.x: API changed significantly. Use 8.x for Flutter 3.x.
- PrivacyInfo.xcprivacy optional: Required since May 1, 2024. Builds uploaded without it receive ITMS-91053 errors.

---

## Open Questions

1. **Does the user have a RevenueCat account and API key configured?**
   - What we know: `purchases_flutter` is not in pubspec.yaml; no RevenueCat dashboard setup is visible in code.
   - What's unclear: Whether the user has products defined in App Store Connect / Play Console, and whether a RevenueCat account exists.
   - Recommendation: The planner should include a Wave 0 task: "Verify RevenueCat account exists and API key is available. If not, create account and configure products before paywall build task."

2. **What subscription products are being sold (price, duration, trial)?**
   - What we know: AdService has `isPremium: bool` parameter suggesting a premium tier was planned.
   - What's unclear: Whether it's annual-only, monthly-only, or both. Trial duration. Price points.
   - Recommendation: Planner should include a task to define product IDs in App Store Connect + Google Play Console and configure them in RevenueCat BEFORE building the paywall widget.

3. **Should the adaptive icon use icon.png as foreground or a separate transparent-background icon mark?**
   - What we know: Adaptive icons require a foreground asset. Using the full icon.png as foreground causes the icon to fill edge-to-edge including the safe zone, which may clip on circular launchers.
   - What's unclear: Whether the user has or can provide a separate foreground-only asset.
   - Recommendation: If user provides only icon.png, use it as foreground with `adaptive_icon_foreground_inset: 20` to add safe zone padding. Note this in plan as a visual quality consideration.

4. **PrivacyInfo.xcprivacy — AdMob and NSPrivacyTracking flag?**
   - What we know: This app uses AdMob but no ATT (App Tracking Transparency) prompt was observed in code.
   - What's unclear: Whether the app shows the ATT prompt (required for personalized ads post-iOS 14.5). If not using ATT prompt, AdMob serves limited ads only.
   - Recommendation: Research this during implementation — check if `AppTrackingTransparency` is listed as a dependency or used in `main.dart`. If absent, `NSPrivacyTracking: false` is correct.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All builds | Yes | 3.41.5 | — |
| Dart SDK | All builds | Yes | 3.11.3 | — |
| flutter_launcher_icons | STORE-01 | Yes (dev dep) | 0.14.4 | — |
| Xcode | iOS builds + PrivacyInfo | Unknown (Linux dev machine) | — | Use CI/cloud build |
| iOS Simulator | Screenshot capture | Unknown | — | Physical device or cloud simulator |
| Android Emulator | Screenshot capture | Unknown | — | Physical device |
| App Store Connect account | STORE-04, submission | Unknown — assumed yes | — | Required: no fallback |
| Google Play Console account | STORE-05, STORE-07 | Unknown — assumed yes | — | Required: no fallback |
| RevenueCat account | STORE-10 | Unknown | — | Cannot submit paywall without this |
| `purchases_flutter` | STORE-10 | Not yet installed | — | Add via `flutter pub add purchases_flutter` |

**Missing dependencies with no fallback:**
- Xcode (required for iOS build + PrivacyInfo validation) — developer is on Linux; iOS builds require macOS. Must use cloud build service (Codemagic, GitHub Actions with macOS runner) or access to a Mac.
- App Store Connect and Google Play Console accounts — assumed available but not verified in code.
- RevenueCat account and API key — required before paywall build begins.

**Missing dependencies with fallback:**
- iOS Simulator for screenshots: physical iPhone works as alternative.
- Android Emulator: physical Android device works as alternative.

---

## Sources

### Primary (HIGH confidence)
- Apple Developer — App Store Connect Screenshot Specifications (official, fetched 2026-03-26): https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/
- Apple Developer — Auto-Renewable Subscriptions (official, fetched 2026-03-26): https://developer.apple.com/app-store/subscriptions/
- Apple Developer — App Review Guidelines 3.1.2 (official, fetched 2026-03-26): https://developer.apple.com/app-store/review/guidelines/
- pub.dev — flutter_launcher_icons documentation (fetched 2026-03-26): https://pub.dev/packages/flutter_launcher_icons
- Google Play — App testing requirements for personal accounts (official): https://support.google.com/googleplay/android-developer/answer/14151465

### Secondary (MEDIUM confidence)
- Google for Developers — AdMob Play data disclosure: https://developers.google.com/admob/android/privacy/play-data-disclosure
- Firebase — Play data disclosure guidance: https://firebase.google.com/docs/android/play-data-disclosure
- Medium — How to Fix ITMS-91053 (API type strings and reason codes): https://medium.com/@vitalib/how-to-fix-itms-91053-missing-api-declaration-0f5f9617c6e4
- RevenueCat — Google Play 14-day testing guide: https://www.revenuecat.com/blog/engineering/google-play-14-day/

### Tertiary (LOW confidence)
- Community guides on adaptive icon configuration — cross-verified with official flutter_launcher_icons docs

---

## Metadata

**Confidence breakdown:**
- Icon generation: HIGH — official package docs fetched, current icon state verified via file inspection
- Screenshot sizes: HIGH — official Apple docs fetched directly; Google Play from official help center
- PrivacyInfo.xcprivacy: MEDIUM — required API types verified via multiple sources; exact set for this stack depends on Xcode's Privacy Report at build time
- Paywall (STORE-10): HIGH on "doesn't exist yet"; MEDIUM on RevenueCat API patterns (based on official pub.dev docs + training knowledge)
- Google Play 14-day gate: HIGH — official Google Play Console help article

**Research date:** 2026-03-26
**Valid until:** 2026-06-26 (Apple screenshot requirements and Play testing rules are stable; privacy manifest requirements may evolve)

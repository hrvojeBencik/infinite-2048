# Phase 5: Store Preparation - Context

**Gathered:** 2026-03-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Prepare complete, compliant App Store and Google Play listings for first public release. Covers: app icon generation (from user-provided source), manual screenshots for required device sizes, ASO-optimized store metadata, iOS PrivacyInfo.xcprivacy manifest, Google Play Data Safety form, paywall compliance audit (Apple 3.1.2), and initiating the Google Play 14-day closed testing gate. No fastlane automation — manual upload workflow.

</domain>

<decisions>
## Implementation Decisions

### App Icon (STORE-01)
- **D-01:** User will provide a custom source icon PNG. Use `flutter_launcher_icons` package to generate all sizes for both platforms from the single source.
- **D-02:** Android adaptive icon uses a solid brand color background layer (hex TBD — user to specify, or Claude picks from AppColors).
- **D-03:** iOS icon must have no alpha channel — `flutter_launcher_icons` handles this via `remove_alpha_ios: true`.

### Screenshots (STORE-02)
- **D-04:** Screenshots captured manually on simulators/devices — no fastlane automation.
- **D-05:** STORE-08 (fastlane pipeline) is descoped from this phase. Screenshots and metadata uploaded directly through App Store Connect and Google Play Console.
- **D-06:** Screenshot scenes: gameplay (active board with tiles), level select/zones, and level complete/achievements. Three key screens minimum per platform.
- **D-07:** Required device sizes: iPhone 6.9", 6.7", 6.5", iPad 13" for iOS; phone + 7" tablet + 10" tablet for Android.

### Store Listing Copy (STORE-04, STORE-05, STORE-09)
- **D-08:** App name: "2048: Merge Quest" — descriptive with keyword "2048" upfront.
- **D-09:** Tone: casual & fun, playful, emoji-friendly, appeals to casual puzzle gamers.
- **D-10:** Category: Games > Puzzle on both platforms.
- **D-11:** Use `/aso-expert` skill to generate fully optimized store listings for both platforms with keyword strategy. The skill analyzes the codebase to discover features automatically.

### Privacy & Compliance (STORE-03, STORE-06, STORE-07)
- **D-12:** Privacy policy URL already live at GitHub Pages (`https://hrvojebencik.github.io/infinite-2048/privacy-policy.html`) via `RemoteConfigService`. Verify it's accessible.
- **D-13:** App collects no extra user data beyond Firebase Analytics (usage data) and AdMob (advertising ID). Firebase Auth is optional — when used, collects Google/Apple identity. PrivacyInfo.xcprivacy and Data Safety form should reflect this.
- **D-14:** No custom identifiers or email collection beyond what Firebase Auth provides.

### Paywall Compliance (STORE-10)
- **D-15:** Custom Flutter paywall screen exists — needs audit against Apple Guideline 3.1.2: must display full annual price, trial terms, and cancel instructions without scrolling.
- **D-16:** Audit the existing paywall widget, identify compliance gaps, and fix before submission.

### Google Play Closed Testing (STORE-02 gate)
- **D-17:** Personal Google Play Developer account — 14-day closed testing gate applies (post-Nov 2023 policy).
- **D-18:** Closed testing track must go live with 12+ testers on day 1 of phase execution. The 14-day clock starts immediately.

### Claude's Discretion
- Adaptive icon background color selection (from existing AppColors)
- PrivacyInfo.xcprivacy exact API declarations based on dependency audit
- Data Safety form field mapping based on SDK analysis
- Screenshot device frame or caption styling (if any post-processing desired)
- Paywall UI fixes — implementation approach for compliance gaps

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### App Icon
- `pubspec.yaml` — Add `flutter_launcher_icons` dev dependency and config section
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` — Current iOS icon assets (will be regenerated)
- `android/app/src/main/res/mipmap-*/` — Current Android icon assets (will be regenerated)

### Privacy & Compliance
- `lib/core/services/remote_config_service.dart` — Privacy policy URL config (`privacyPolicyUrl` getter, line ~39)
- `ios/Runner/` — PrivacyInfo.xcprivacy needs to be created here
- `lib/core/services/analytics_service.dart` — Firebase Analytics events (determines privacy declarations)
- `lib/core/services/ad_service.dart` — AdMob integration (determines advertising data declarations)

### Paywall
- `lib/features/home/presentation/pages/home_page.dart` — Contains premium/paywall entry points
- `lib/features/progression/presentation/pages/theme_selection_page.dart` — Premium theme gating
- Find the actual paywall widget (not found in subscription feature dir — may be inline or in a different location)

### Store Metadata
- `.planning/REQUIREMENTS.md` — STORE-01 through STORE-10 requirements
- Run `/aso-expert` skill during execution to generate `STORE_LISTING.md`

### Theme & Branding
- `lib/core/theme/app_colors.dart` — Brand colors for adaptive icon background
- `lib/core/theme/app_theme.dart` — App theme reference

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **RemoteConfigService**: Already has `privacyPolicyUrl` getter pointing to GitHub Pages URL
- **AppColors / AppTheme**: Brand colors available for adaptive icon background selection
- **Settings page**: Already links to privacy policy URL (line ~149)

### Established Patterns
- **Dev dependency usage**: `flutter_native_splash` already used as dev dep with pubspec config (Phase 3) — same pattern for `flutter_launcher_icons`
- **Asset organization**: Icons in standard Flutter locations (`ios/Runner/Assets.xcassets/`, `android/app/src/main/res/`)

### Integration Points
- **pubspec.yaml**: Add `flutter_launcher_icons` config and dev dependency
- **ios/Runner/PrivacyInfo.xcprivacy**: New file — Apple privacy manifest
- **Paywall widget**: Needs to be located and audited for 3.1.2 compliance

</code_context>

<specifics>
## Specific Ideas

- App version needs bumping from `1.0.0+1` to appropriate release version before store submission
- Google Play closed testing should start on day 1 — the 14-day gate is a calendar blocker, not a code task

</specifics>

<deferred>
## Deferred Ideas

### Descoped from Phase 5
- **STORE-08 (Fastlane pipeline)**: User chose manual screenshot capture and direct store upload — no fastlane automation needed for v1.2 launch. Can add in future milestone for CI/CD.

</deferred>

---

*Phase: 05-store-preparation*
*Context gathered: 2026-03-26*

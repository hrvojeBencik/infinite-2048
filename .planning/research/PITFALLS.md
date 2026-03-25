# Pitfalls Research

**Domain:** Flutter mobile game — polish, performance optimization, and store preparation
**Researched:** 2026-03-25
**Confidence:** HIGH (verified with official Flutter docs, Apple/Google developer docs, RevenueCat docs, community post-mortems)

---

## Critical Pitfalls

### Pitfall 1: Testing Animations in Debug Mode and Shipping Blind

**What goes wrong:**
Developers add tile merge animations, screen transitions, and particle effects, test them in `flutter run` (JIT/debug mode), see acceptable results, then ship. On users' devices, animations that looked fine in debug mode stutter or drop frames because debug mode is 2-3x slower than production. The developer never discovers this until users leave 1-star reviews.

**Why it happens:**
Debug mode uses JIT compilation with extra framework checks and state tracking. It is intentionally slow. Animations appear to pass visual inspection but mask real performance issues. Release builds use AOT compilation — the gap is dramatic.

**How to avoid:**
Profile animations exclusively in `flutter run --profile` on a **physical device** (not simulator). The DevTools Performance tab in profile mode shows real frame timings. Target every animation frame under 16ms (60fps) or 8ms (120fps on high-refresh devices). Never sign off on animation quality from a simulator or debug build.

**Warning signs:**
- All testing done via `flutter run` on simulator
- No DevTools Performance tab opened during development
- Animations look "a bit choppy" in debug — they will be worse in production if uncached

**Phase to address:**
Performance & Jank phase — establish profile-mode testing as the baseline before any animation work begins.

---

### Pitfall 2: BLoC Rebuilding the Entire Board on Every Game State Emission

**What goes wrong:**
`GameBloc` emits a new `GameState` on every move (tile positions, score, board). A `BlocBuilder<GameBloc, GameState>` wrapping the entire game grid rebuilds every tile widget — 16 widgets — on every swipe. When tile merge animations are added on top, this triggers cascading rebuilds during the animation tick, causing dropped frames on mid-range Android devices.

**Why it happens:**
Clean Architecture produces a clean, complete state object per event. The natural BLoC usage rebuilds everything that depends on that state. Adding animations inside `BlocBuilder` compounds this: the animation controller fires 60 times per second, and if it lives inside the same subtree as `buildWhen`-less BlocBuilder, the board repaints 60 times per frame.

**How to avoid:**
Use `buildWhen` to scope rebuilds to only what changed. Separate animated tile widgets from board-level state consumers. Wrap the game grid in `RepaintBoundary` so tile animations don't dirty the score/header area. Use `AnimatedBuilder` with a tight subtree — pass the non-animated child as a parameter, not inside the builder function.

```dart
// BAD: rebuilds entire subtree every animation tick
AnimatedBuilder(
  animation: _controller,
  builder: (context, _) {
    return Column(children: [Header(), TileGrid(), Footer()]);
  },
)

// GOOD: only TileGrid repaints
AnimatedBuilder(
  animation: _controller,
  child: Footer(), // built once
  builder: (context, child) {
    return Column(children: [Header(), TileGrid(), child!]);
  },
)
```

**Warning signs:**
- "Repaint Rainbow" in DevTools shows the score display repainting during tile animations
- Frame builds spike above 16ms on moves but not on idle
- Profile mode shows `build()` in the top flame chart entries during swipes

**Phase to address:**
Animations & Transitions phase — audit `buildWhen` usage and `RepaintBoundary` placement before adding any new animations.

---

### Pitfall 3: Google Play Closed Testing Gate Blocking Launch

**What goes wrong:**
Developer accounts created after November 13, 2023 (personal accounts) cannot publish to production without first completing a closed testing period: at least **12 testers opted-in for 14 consecutive days**. Many first-time publishers discover this gate only after completing all store preparation work, delaying launch by 2+ weeks.

**Why it happens:**
Google introduced this requirement to reduce low-quality apps. It is buried in policy documentation and not prominently displayed until you attempt to submit to production. Developers assume closed testing is optional.

**How to avoid:**
Start closed testing immediately when store preparation begins — do not wait until store listing is complete. Recruit 12 testers (friends, beta community, social media) on day 1 of the store prep phase. The 14-day clock starts when testers opt in, not when the APK is uploaded.

**Warning signs:**
- First-time Google Play developer account (personal, not organization)
- No closed test track exists yet in Play Console
- Store listing work started without verifying account type and testing gate status

**Phase to address:**
Store Preparation phase — make "launch closed test track" the first task, not the last.

---

### Pitfall 4: RevenueCat Paywall Rejected for Subscription Clarity Violations

**What goes wrong:**
Apple rejects the app under Guideline 3.1.2 (Subscriptions: Ongoing Value) or related guidelines because the paywall does not clearly display: the full billed amount (e.g., "$49.99/year", not just "$4.16/month"), the introductory offer terms, how to cancel, and accessible links to both Privacy Policy and Terms of Service. A partial disclosure is enough to trigger rejection with a re-review cycle.

**Why it happens:**
Developers build paywalls focused on conversion design (highlighting monthly cost) rather than disclosure requirements. RevenueCat's SDK handles purchase mechanics but the UI disclosure is the developer's responsibility. Apple reviewers check paywalls manually and methodically.

**How to avoid:**
The paywall must show simultaneously: annual price as the full charged amount, free trial terms (exact duration, what happens after), cancel instructions, and tappable Privacy Policy + Terms links. Use RevenueCat's official paywall review checklist before submission. Test the paywall in Sandbox mode with a reviewer mindset, not a conversion mindset.

**Warning signs:**
- Paywall shows only the per-month normalized price
- Free trial duration is in fine print or not shown
- Privacy Policy and Terms links require scrolling to find
- Paywall was designed to maximize conversion without a compliance review

**Phase to address:**
Store Preparation phase — run the paywall against RevenueCat's review guidelines before submission, not after the first rejection.

---

### Pitfall 5: Hive Schema Changes Corrupting Existing User Data on Update

**What goes wrong:**
A polish pass requires restructuring `PlayerProfile`, `GameState`, or achievement data stored in Hive. Adding a non-nullable field, changing a field's type, or renaming an adapter causes a `type cast` exception on app launch for existing users who have v1.1.0 data. The app crashes on open for all users who upgrade.

**Why it happens:**
Hive does not have built-in schema migration like SQL databases. When a `TypeAdapter` changes, existing binary data on device does not automatically conform to the new schema. If the new code reads an old box and a field is missing or incompatible, it throws at runtime — not at compile time.

**How to avoid:**
Never change an existing `HiveField` index. Add new fields as nullable with defaults. When structural changes are unavoidable: version the box name (e.g., `playerProfile_v2`), read the old box on startup, migrate to new schema, delete the old box. Test migration with a device that has existing v1.1.0 data, not a fresh install. The v1.2 polish pass should treat all Hive adapters as write-protected unless migration logic is explicitly written.

**Warning signs:**
- Any change to a `@HiveType` or `@HiveField` annotated class
- Adding required (non-nullable) fields to existing adapters
- Running only on fresh installs during development (no upgrade test)

**Phase to address:**
Visual Design & Theme phase if tile theme data changes; UX Flow phase if profile/settings data changes. Any phase touching persistence must include an upgrade test from v1.1.0 data.

---

### Pitfall 6: `audioplayers` Memory Leak from Undisposed Players During Rapid Sound Playback

**What goes wrong:**
The game fires sound effects on every tile merge — in rapid swipe sequences, this creates many `AudioPlayer` instances in quick succession. Without proper disposal, instances accumulate in memory. After 20-30 minutes of gameplay, audio starts failing silently, then the app's memory usage spikes, eventually causing an OOM crash on lower-end Android devices.

**Why it happens:**
`audioplayers` creates native audio handles per player instance. The Flutter GC cleans up the Dart object but does not guarantee native resource release. For one-shot sound effects, many developers play and forget without explicitly calling `dispose()`.

**How to avoid:**
Use a pooled `AudioPlayer` approach: pre-create a fixed set of players (e.g., 3-4 for simultaneous sounds), reuse them in rotation, never create a new instance per sound event. Alternatively, evaluate `flutter_soloud` — it is now the officially recommended library for low-latency game audio and handles pooling natively. Dispose all players in `SoundService.dispose()`.

**Warning signs:**
- `SoundService` creates a new `AudioPlayer()` inside the method that plays the sound
- No `dispose()` call in `SoundService` teardown
- Memory grows visibly in DevTools Memory tab during extended play sessions
- Audio stops working after 30+ minutes of play

**Phase to address:**
Performance & Jank phase — audit SoundService as part of memory profiling pass.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Hardcoding animation durations as magic numbers | Faster to write | Cannot A/B test; inconsistent feel across screens | Never — use named constants in `GameConstants` |
| Testing only on flagship device (Pixel 9, iPhone 16 Pro) | Convenient | Ships janky to mid-range/budget devices (majority of market) | Never for release builds |
| Skipping profile-mode testing for "obviously fast" widgets | Saves time | Deferred jank discovery to user reviews | Never |
| Using `Opacity` widget for fade animations | Simpler API | Creates saveLayer call, very expensive | Never — use `AnimatedOpacity` or `FadeTransition` |
| Not versioning Hive box names | Less code | Silent corruption on schema change for existing users | Never |
| Showing ads immediately on game start without delay | Max impressions | App Store / Play Store UX violation, higher uninstall rate | Never |
| Keyword stuffing in App Store title or description | Perceived discoverability | Rejection or penalty from stores; lower ranking | Never |

---

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| RevenueCat paywall | Showing only normalized monthly price ($4.16/mo) | Show full annual charge ($49.99/yr) **and** the monthly breakdown |
| RevenueCat paywall | No cancel instructions on screen | Explicit "Cancel anytime in Settings" text is required by Apple |
| AdMob interstitials | Showing interstitial immediately after game over with no delay | Minimum recommended gap between interstitials is 5 minutes; apply in-code frequency check |
| AdMob app open ads | Showing app open ad on every cold start including after purchase | Check subscription status before showing; premium users must never see ads |
| Firebase optional init | Firebase crash on secondary service (Analytics) blocking game start | All Firebase services must be individually guarded — one service failing must not cascade |
| Google Play Data Safety | Leaving data safety form incomplete at submission | All SDKs (AdMob, Firebase, RevenueCat) must be declared; incomplete form causes rejection |
| App Store privacy manifest | Missing `NSPrivacyAccessedAPITypes` for Hive/UserDefaults usage | Required since iOS 17 for apps using disk access APIs; missing causes App Store rejection |

---

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| `Opacity` widget in animations | Consistent 2-4ms frame overhead per animated opacity; "Repaint Rainbow" shows large repaint regions | Replace with `AnimatedOpacity` or `FadeTransition` which use compositing layer instead of saveLayer | Any animation using opacity |
| Overusing `RepaintBoundary` | Memory grows without jank improvement; too many cached layers | Wrap only widgets with high repaint frequency AND high render cost (game grid, looping effects) | More than ~10 boundaries in a single screen |
| Large PNG assets not downsampled to widget size | First render of any screen with these assets spikes frame time 50-100ms | Use `ResizeImage` wrapper or pre-scale assets to max display resolution at build time | Every screen transition involving large assets |
| AnimationController not disposed | Memory leak; "setState called after dispose" errors | Override `dispose()` in every `State` that creates a controller | After navigating away from a screen and back repeatedly |
| `BlocBuilder` without `buildWhen` on high-frequency state | Entire widget subtree rebuilds on every game tick | Add `buildWhen: (prev, next) => prev.score != next.score` or similar narrow condition | Games with frequent state updates (every swipe) |
| Shader warmup not triggered before first animation | First animation on a cold start stutters badly ("first frame jank") | Use `flutter_shaders` or trigger `precacheImage`/`SchedulerBinding.instance.scheduleWarmUpFrame` | Cold start on any device, especially Android |

---

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Storing RevenueCat API key in source code | Key leakage via public repo; unauthorized purchase validation | Use `--dart-define` or `flutter_dotenv`; never hardcode in `AppConstants` |
| Not enabling App Attest / Play Integrity API | Score manipulation by rooted/emulated devices, fake leaderboard entries | Enable Play Integrity on Google Play, App Attest on iOS; validate server-side for leaderboard writes |
| Firebase Firestore rules allowing unauthenticated writes to leaderboard | Leaderboard spam and score injection | Firestore rules must require `request.auth != null` for all leaderboard write paths |
| Shipping with `kDebugMode` dev tools accessible in prod | Dev routes (`/dev/sandbox`) expose game engine internals | `kDebugMode` guard is already in place per CLAUDE.md — verify it survives release build compilation |

---

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Changing swipe gesture sensitivity during polish | Existing users find the game "feels wrong"; muscle memory broken; negative reviews citing "ruined controls" | Do not change gesture detection thresholds in v1.2; flag as v1.3 experiment with A/B testing |
| Adding mandatory animation that blocks input | Users swipe before animation finishes and the input is dropped; feels unresponsive | Queue input during animation rather than ignoring it; OR keep animation under 200ms |
| Modal paywall on second app open | Users who haven't seen the game yet are asked to pay; high dismiss rate, negative first impression | Show paywall only after user completes first level or achieves a milestone |
| Changing onboarding flow for existing users | Existing users who have `onboardingComplete = true` suddenly see onboarding again after update | Gate onboarding redisplay on a version flag, not just the completion bool |
| Over-animating the home screen | Home screen loads feel slow; users interpret animation as lag even if framerate is 60fps | Home screen transitions should be under 300ms total; reserve elaborate animations for in-game events |
| Removing features that existed in v1.1.0 | Users who relied on the feature leave negative reviews | v1.2 is polish-only; no feature removal without explicit opt-out path and communication |

---

## "Looks Done But Isn't" Checklist

- [ ] **Store Screenshots:** Screenshots match current app UI exactly — not from an earlier build or Figma mockup. Apple rejects screenshots showing features not present in the submitted build.
- [ ] **App Icon:** Icon passes both the iOS icon review (no rounded corners pre-applied, no transparency, correct resolution 1024x1024) and the Google Play adaptive icon test (safe zone content not clipped).
- [ ] **Privacy Policy URL:** URL is live, publicly accessible, not gated, not a PDF, not a GitHub Pages URL that returns 404 on path. Required by both stores and RevenueCat.
- [ ] **Subscription trial language:** Free trial duration, what happens after trial, and how to cancel are all visible on the paywall without scrolling on a standard phone screen.
- [ ] **Ad-free for premium users:** Every ad placement (interstitial, app open, banner) is individually guarded by a subscription status check — not just the paywall entry point.
- [ ] **Release build tested:** Final store build (`flutter build appbundle --release` / `flutter build ios --release`) opened on a physical device and all core flows exercised — not just simulator or debug.
- [ ] **Google Play Closed Testing:** 12 testers have been opted in for at least 14 consecutive days before production submission attempt.
- [ ] **Data Safety form:** AdMob, Firebase Analytics, RevenueCat, and Hive data collection all declared accurately in Google Play Data Safety section.
- [ ] **iOS Privacy Manifest:** `PrivacyInfo.xcprivacy` present and declares all required reason APIs (disk space APIs used by Hive, UserDefaults access).
- [ ] **Audio on silent mode (iOS):** Sound effects should not override the system silent switch unless explicitly needed. Verify audioplayers session category is `.ambient` not `.playback`.
- [ ] **Hive upgrade path:** App tested by installing v1.1.0, writing game data, then upgrading to v1.2.0 — no crash on launch.
- [ ] **Firebase-off mode:** App launched with Firebase disabled (airplane mode, Firebase unavailable) — no error dialogs, no crash, all features degrade gracefully.

---

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| App Store rejection for paywall disclosure | LOW | Update paywall UI to show required fields, resubmit. Review typically takes 24-48 hours. |
| Google Play production gate — no testers | HIGH | 14+ days minimum delay. Start immediately. Cannot be shortcut. |
| Hive schema corruption for existing users | HIGH | Emergency hotfix: detect old schema on launch, delete corrupted box (accept data loss), re-initialize with defaults. Communicate in release notes. |
| Shipped jank discovered post-release | MEDIUM | Profile mode audit, targeted RepaintBoundary/buildWhen fixes, hotfix release. |
| Audio memory leak causing crash after 30min | MEDIUM | Patch SoundService to use pooled players, hotfix release. |
| App Store rejection for metadata/screenshots | LOW | Fix specific flagged items, resubmit. Typically 1-2 day turnaround. |
| Firebase-dependent feature crashes app | MEDIUM | Add per-feature null guards; these should already be in place per the optional Firebase design, but verify each service is individually guarded. |

---

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Debug-mode animation testing | Performance & Jank | All animation sign-off done in `--profile` mode on physical device |
| BLoC rebuild on every game tick | Animations & Transitions | DevTools Repaint Rainbow shows no full-board repaints during moves |
| Google Play closed testing gate | Store Preparation (start of phase) | Closed test track live with 12 testers on day 1 of phase |
| RevenueCat paywall rejection | Store Preparation | Paywall checklist reviewed against RevenueCat guidelines before submission |
| Hive schema corruption on upgrade | Visual Design / UX Flow (whichever touches data) | Upgrade test from v1.1.0 build passes with no crash |
| audioplayers memory leak | Performance & Jank | Memory profiler shows flat memory over 30-min play session |
| Gesture sensitivity regression | Animations & Transitions | Manual regression test of existing swipe behavior before and after animation changes |
| Keyword stuffing metadata | Store Preparation | Metadata review against App Store and Play Store guidelines before submission |
| Input dropped during animations | Animations & Transitions | Rapid swipe test: 10 swipes in 2 seconds, all 10 processed |
| Missing iOS privacy manifest | Store Preparation | `flutter build ios` produces no missing-entitlement warnings; App Store Connect upload succeeds |

---

## Sources

- [Flutter Performance Best Practices — official](https://docs.flutter.dev/perf/best-practices)
- [Flutter Rendering Performance — official](https://docs.flutter.dev/perf/rendering-performance)
- [Flutter Build Modes — official](https://docs.flutter.dev/testing/build-modes)
- [Flutter Performance Profiling — official](https://docs.flutter.dev/perf/ui-performance)
- [Getting your paywall approved through App Review — RevenueCat](https://www.revenuecat.com/docs/tools/paywalls/creating-paywalls/app-review)
- [The ultimate guide to App Store rejections — RevenueCat](https://www.revenuecat.com/blog/growth/the-ultimate-guide-to-app-store-rejections/)
- [Google Play App Testing Requirements — official](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en)
- [App Store Screenshot Specifications — Apple Developer](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
- [Google Play Data Safety — official](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en)
- [AdMob Frequency Capping — official](https://support.google.com/admob/answer/6244508?hl=en)
- [Flutter Animation Performance — Digia Tech](https://www.digia.tech/post/flutter-animation-performance-guide)
- [RepaintBoundary as Secret Weapon Against Jank — Medium/Saropa](https://saropa-contacts.medium.com/why-flutters-repaintboundary-is-your-secret-weapon-against-jank-c610194a1ce4)
- [How We Reduced Flutter Memory Usage by 375mb — Medium/Saropa](https://saropa-contacts.medium.com/how-we-reduced-flutter-memory-usage-by-375mb-image-optimization-strategies-5a097246ee0c)
- [Flutter: Stop Using Audioplayers — Medium/Easy Flutter](https://medium.com/easy-flutter/flutter-stop-using-audioplayers-use-this-instead-4030800a4107)
- [Hive Database Migration — GitHub Issue #487](https://github.com/isar/hive/issues/487)
- [Google Play Developer Policy Changes 2026 — OpenForge](https://openforge.io/google-play-developer-policy-changes-that-matter-in-2026/)
- [ASO Mistakes — MobileAction](https://www.mobileaction.co/blog/aso-mistakes/)

---
*Pitfalls research for: Flutter mobile game polish, performance optimization, store preparation*
*Researched: 2026-03-25*

# Phase 4: UX Flow and Usability - Research

**Researched:** 2026-03-26
**Domain:** Flutter UX — onboarding, daily challenge surfacing, in-app review, ad frequency gating, score sharing
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Onboarding Skip (UX-01)
- **D-01:** Skip button visible immediately from the first tutorial step — a "Skip" text button in the top-right corner of the `TutorialOverlay`.
- **D-02:** Tapping skip dismisses the overlay and marks onboarding as complete via `OnboardingLocalDataSource`. Returning users never see the tutorial again.

#### Daily Challenge on Home (UX-02)
- **D-03:** Prominent styled card at the top of the home screen, above the main menu options.
- **D-04:** Card shows today's challenge info (target tile, board size, time remaining). Tapping launches the daily challenge game. If already completed today, shows a checkmark/completed state.

#### Review Prompt (UX-03)
- **D-05:** Review prompt fires after level complete using the existing `RateAppService`. Respects OS frequency limits (iOS only shows once per app version, Android respects Play quota).

#### Ad Frequency (UX-04)
- **D-06:** Ad frequency defaults to every 3 levels, configurable via remote config. Premium (subscription) users never see interstitials.

#### Score Sharing (UX-05)
- **D-07:** Add `share_plus` package to pubspec.yaml.
- **D-08:** Share button appears on both the level complete dialog and game over dialog.
- **D-09:** Shared image is a styled branded card rendered as a widget, captured via `RepaintBoundary` + `RenderRepaintBoundary.toImage()`. Card contains: score, highest tile reached, level number, and app name/logo.
- **D-10:** Share via native share sheet using `SharePlus.instance.share(params)` with the rendered image.

### Claude's Discretion
- Daily challenge card visual design and layout
- Share card visual design (colors, typography, layout)
- Ad frequency remote config key name
- Review prompt timing (immediate after dialog or delayed)
- Whether to use `in_app_review` directly or wrap through RateAppService

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| UX-01 | User can skip onboarding tutorial | Skip button added to `TutorialOverlay`; calls `OnboardingLocalDataSource.markTutorialCompleted()` |
| UX-02 | Ad frequency capped via remote config (default: every 3 levels) | `AdService.onLevelCompleted()` reads threshold from `RemoteConfigService`; premium guard via `AuthBloc` |
| UX-03 | Review prompt appears after level completion (respects OS limits) | `RateAppService.requestReview()` already wired in `_checkRateAppPrompt()` — needs minor timing fix |
| UX-04 | Daily challenge card visible on home screen | `_DailyChallengeCard` already exists in `home_page.dart` but is below menu buttons — must be repositioned above them |
| UX-05 | User can share score as image from game over / level complete screen | `share_plus` 12.0.1 not yet in pubspec; `RepaintBoundary.toImage()` pattern documented and ready |
</phase_requirements>

---

## Summary

Phase 4 is primarily a **wiring and repositioning** phase. Much of the infrastructure is already present — `RateAppService`, `AdService`, `OnboardingLocalDataSource`, `AchievementsBloc` with daily challenge state, and the `_DailyChallengeCard` widget in `home_page.dart` — but it needs to be connected, repositioned, or extended with a new package.

The most significant new work is score sharing (UX-05): adding `share_plus`, creating a `ShareCard` widget that is renderable to an image via `RepaintBoundary`, and integrating share buttons into both dialogs. The second most significant is the daily challenge card repositioning (UX-02 mapped to D-03): the card already exists in `home_page.dart` but renders below Endless Mode, not above the main menu. Ad frequency (UX-04) requires adding a premium guard to `AdService.onLevelCompleted()` and wiring `RemoteConfigService` to supply the threshold.

The review prompt (UX-03) is almost entirely implemented — `_checkRateAppPrompt()` is already called in `_trackAchievements()` — but fires immediately after dialog display because `Future.delayed(2s)` runs concurrently with the level complete animation. The onboarding skip (UX-01) is a single-widget edit to `TutorialOverlay`.

**Primary recommendation:** Execute in dependency order — UX-01 (standalone widget edit) → UX-04 (service wiring) → UX-03 (timing review) → UX-02 (card reposition) → UX-05 (new package + share card).

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| share_plus | ^10.0.0 or ^12.0.1 | Native share sheet with file support | Flutter Community official plugin; wraps UIActivityViewController (iOS) / ACTION_SEND (Android) |
| in_app_review | 2.0.11 (already installed) | OS-native review prompt | Already in pubspec; wraps SKStoreReviewController / Play In-App Review API |
| flutter_bloc | 9.1.1 (already installed) | State for premium check | Already used throughout app |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| path_provider | 2.1.5 (already installed) | Temp directory for share image | Already in pubspec; needed to write PNG before sharing |
| cross_file | transitive via share_plus | XFile wrapper for share API | Comes with share_plus; used for `ShareParams(files: [XFile(path)])` |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| share_plus | screenshot package | screenshot adds another render tree; RepaintBoundary is already the established pattern in this codebase (Phase 2) |
| RateAppService wrapper | Call in_app_review directly | RateAppService already encapsulates throttle logic (5 levels first trigger, 15 thereafter, 3-day cooldown) — no reason to bypass it |

### Installation
```bash
flutter pub add share_plus
flutter pub get
```

**Version note:** `share_plus` 12.0.1 is the latest stable as of March 2026 (published ~5 months ago). The API changed in v10+: static `Share.shareXFiles()` is deprecated in favor of `SharePlus.instance.share(params)` with `ShareParams`. Use `^10.0.0` constraint to allow patch updates while avoiding a hypothetical v13 break.

---

## Architecture Patterns

### Recommended Project Structure

No new top-level directories. New files follow existing conventions:

```
lib/
  core/
    services/
      ad_service.dart           # MODIFY: add premium guard + remote config threshold
      remote_config_service.dart # MODIFY: add ad_frequency_level_count key
  features/
    game/
      presentation/
        widgets/
          level_complete_dialog.dart  # MODIFY: add share button + RepaintBoundary wrapping share card
          game_over_dialog.dart       # MODIFY: add share button
          share_score_card.dart       # NEW: the branded card widget rendered to image
    onboarding/
      presentation/
        widgets/
          tutorial_overlay.dart  # MODIFY: add skip button overlay in Stack
    home/
      presentation/
        pages/
          home_page.dart   # MODIFY: move _DailyChallengeCard above _PlayButton
```

### Pattern 1: Widget-to-Image Capture (RepaintBoundary)

**What:** Wrap a widget in `RepaintBoundary` with a `GlobalKey`, then capture to PNG via `RenderRepaintBoundary.toImage()`.
**When to use:** Score share card — the card is built as a Flutter widget, captured to bytes, written to a temp file, then handed to `share_plus`.

```dart
// Existing pattern already in this codebase (Phase 2):
// RepaintBoundary used for render isolation on board/score/powerup zones.
// Same pattern applied here for capture:

final _shareCardKey = GlobalKey();

// In widget tree:
RepaintBoundary(
  key: _shareCardKey,
  child: ShareScoreCard(score: ..., highestTile: ..., levelNumber: ...),
)

// Capture method:
Future<void> _shareScore() async {
  final boundary = _shareCardKey.currentContext!
      .findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/score_share.png');
  await file.writeAsBytes(pngBytes);

  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)]),
  );
}
```

**Source:** [Flutter official API - RenderRepaintBoundary.toImage](https://api.flutter.dev/flutter/rendering/RenderRepaintBoundary/toImage.html)

**Known constraint:** `toImage()` requires the widget to have been painted at least once (i.e., `debugNeedsPaint` must be false). The `_shareCardKey` widget must be in the live widget tree before capture is attempted. The share card should be rendered but visually hidden (e.g., positioned off-screen or at zero opacity) until capture is needed, or can be rendered inside the dialog itself.

### Pattern 2: SharePlus Modern API (v10+)

**What:** Use `SharePlus.instance.share(ShareParams(...))` — the static `Share.shareXFiles()` is deprecated as of v10.

```dart
import 'package:share_plus/share_plus.dart';

await SharePlus.instance.share(
  ShareParams(
    files: [XFile(file.path)],
    // Optional: subject for email clients
    subject: 'My 2048 Score',
  ),
);
```

**Source:** pub.dev share_plus 12.0.1 documentation

### Pattern 3: Remote Config Ad Threshold

**What:** `RemoteConfigService` already initializes Firebase Remote Config. Add a new key `ad_frequency_level_count` with default value `3`. `AdService.onLevelCompleted()` reads this key instead of the hardcoded `3`.

```dart
// In RemoteConfigService:
static const _keyAdFrequency = 'ad_frequency_level_count';
static const _defaultAdFrequency = 3;

int get adFrequencyLevelCount =>
    _remoteConfig?.getInt(_keyAdFrequency) ?? _defaultAdFrequency;

// In AdService — add to initDependencies wiring or inject via constructor:
void onLevelCompleted({required bool isPremium}) {
  if (!_initialized || isPremium) return;
  _levelsCompletedSinceAd++;
  final threshold = sl<RemoteConfigService>().adFrequencyLevelCount;
  if (_levelsCompletedSinceAd >= threshold) {
    showInterstitial();
    _levelsCompletedSinceAd = 0;
  }
}
```

**Premium check source:** `AppUser.isPremium` already exists on the `AuthBloc` state. In `game_page.dart`'s `_showLevelComplete()`, read `context.read<AuthBloc>().state` and extract `isPremium` from `AuthAuthenticated`.

### Pattern 4: Skip Button Overlay in TutorialOverlay

**What:** The `TutorialOverlay` already uses a `Stack`. Add a `Positioned` skip button in the top-right of the Stack.

```dart
// In _TutorialOverlayState.build():
Stack(
  alignment: Alignment.center,
  children: [
    // ... existing background + GlassCard ...
    Positioned(
      top: 16,
      right: 16,
      child: TextButton(
        onPressed: _skipTutorial,
        child: const Text(
          'Skip',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    ),
  ],
)

void _skipTutorial() {
  sl<OnboardingLocalDataSource>().markTutorialCompleted();
  widget.onComplete();
}
```

**Note:** `onComplete` in `game_page.dart` already calls `_onTutorialComplete()`, which marks the tutorial done and hides the overlay. The skip path can call `onComplete` directly since `_onTutorialComplete` handles both state update and analytics. However, to avoid analytics logging `logTutorialCompleted` on a skip, a separate `onSkip` callback may be cleaner — this is Claude's discretion per CONTEXT.md.

### Pattern 5: Daily Challenge Card Repositioning

**What:** `_DailyChallengeCard` already exists in `home_page.dart`. It currently appears after `_EndlessModeButton` (delay: 450ms). D-03 requires it above the main menu options, meaning above `_PlayButton`.

```dart
// Current order (home_page.dart ~line 78):
// _PlayButton, _EndlessModeButton, _DailyChallengeCard, _WeeklyChallengeCard

// Required order:
// _DailyChallengeCard (prominent, above play)
// _PlayButton
// _EndlessModeButton
// _WeeklyChallengeCard
```

**Note from code audit:** The `_DailyChallengeCard` shows `SizedBox.shrink()` when `state is! AchievementsLoaded || state.dailyChallenge == null`. This means on initial load (AchievementsLoading state) the card is invisible. Consider whether a loading skeleton or minimum-height placeholder is needed to prevent layout shift. This is Claude's discretion.

### Anti-Patterns to Avoid

- **Calling `requestReview()` from a button press:** iOS/Android both enforce quotas and may silently reject calls that appear user-initiated. Always call via `RateAppService.shouldPromptForReview()` guard.
- **Capturing RepaintBoundary before first frame:** `toImage()` throws if the widget hasn't been painted. Always call via `WidgetsBinding.instance.addPostFrameCallback` or after a `Future.delayed(Duration.zero)` if timing is uncertain.
- **Using deprecated `Share.shareXFiles()`:** Produces deprecation warnings in share_plus 10+. Use `SharePlus.instance.share(ShareParams(...))`.
- **Writing temp files without `path_provider`:** Always use `getTemporaryDirectory()` — hardcoding paths fails on both iOS (sandboxed) and Android (scoped storage).
- **Hardcoding ad frequency in AdService:** The existing `if (_levelsCompletedSinceAd >= 3)` is the current bug — this must be replaced with a `RemoteConfigService` call.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Native share sheet | Custom share UI | share_plus 12.0.1 | Platform-specific sheet (iOS UIActivityViewController, Android Intent) handles all app targets (Messages, WhatsApp, email, etc.) |
| OS review dialog | Custom review prompt / star rating UI | in_app_review (already installed) | App store guidelines prohibit custom review prompts that ask for ratings before showing the OS dialog |
| Image byte conversion | Manual pixel manipulation | `RenderRepaintBoundary.toImage()` + `toByteData(format: png)` | Flutter's official capture path; handles DPR scaling correctly with pixelRatio param |
| Temp file management | Custom file paths | path_provider `getTemporaryDirectory()` | Handles iOS sandbox and Android scoped storage correctly |

---

## Common Pitfalls

### Pitfall 1: Share Button Triggers Capture Before Widget Renders

**What goes wrong:** The share card widget (inside a dialog) hasn't painted when the user taps "Share" milliseconds after dialog open. `toImage()` throws `"Render object has not been laid out."` or returns a blank image.
**Why it happens:** Dialog animation is 350ms; widget may not be fully painted within first frame after `showGeneralDialog`.
**How to avoid:** Delay capture by at least one frame after the dialog is displayed. Use `WidgetsBinding.instance.addPostFrameCallback` or `await Future.delayed(Duration.zero)` inside `_shareScore()`. Better: put a loading indicator on the share button during capture.
**Warning signs:** Users report blank/black share images.

### Pitfall 2: Premium Check Uses Stale Auth State

**What goes wrong:** Ad shows to a premium user because `AuthBloc` state hasn't updated from Firestore yet (lazy load, Firebase optional).
**Why it happens:** Firebase auth is optional — `AuthBloc` may be in `AuthInitial` or `AuthLoading` state at level complete time.
**How to avoid:** In `_showLevelComplete()`, check `authState is AuthAuthenticated && authState.user.isPremium`. If auth is not authenticated (guest/offline), treat as free user (show ads). This is the safe default.
**Warning signs:** Premium users occasionally seeing ads after first install or after returning from background.

### Pitfall 3: RemoteConfigService Returns Default If Firebase Unavailable

**What goes wrong:** The `adFrequencyLevelCount` getter returns `null` when Firebase failed to initialize, causing a null cast error or incorrect threshold.
**Why it happens:** `_remoteConfig` is nullable in `RemoteConfigService` — Firebase init is `try/catch` wrapped. `_remoteConfig?.getInt(key)` returns `null` when `_remoteConfig` is null.
**How to avoid:** Always use null-coalescing with the hardcoded default: `_remoteConfig?.getInt(_keyAdFrequency) ?? _defaultAdFrequency`. The pattern is already established in `RemoteConfigService` for other keys.
**Warning signs:** Ad never shows (threshold resolves to 0) or crashes with null on non-Firebase builds.

### Pitfall 4: Daily Challenge Card Layout Shift on AchievementsLoading

**What goes wrong:** The card is `SizedBox.shrink()` during `AchievementsLoading`, then expands when loaded — causes jarring layout shift that pushes `_PlayButton` down.
**Why it happens:** `_DailyChallengeCard` returns `SizedBox.shrink()` for non-loaded states. When placed first in column, this causes the whole layout to reflow.
**How to avoid:** Either (a) use `AnimatedSize` wrapping the card, or (b) return a fixed-height shimmer/skeleton during loading, or (c) accept the shift (it's sub-second on first load). Decision is Claude's discretion.

### Pitfall 5: `RateAppService.recordLevelCompleted()` Already Called But `shouldPromptForReview()` Never Triggers

**What goes wrong:** `recordLevelCompleted()` increments the counter but `shouldPromptForReview()` returns `false` indefinitely, so review is never requested.
**Why it happens:** `_keyHasRated` is persisted as `true` after first `requestReview()` call — the service permanently suppresses future prompts once it considers the user has rated. Also, the 3-day cooldown between prompts applies.
**How to avoid:** This is by design. The existing logic is correct. For testing, call `OnboardingLocalDataSource.resetTutorial()` equivalent on the rate box. No code change needed — just understand the intentional throttle.
**Warning signs (for planning):** UX-03 success criterion is met as long as the prompt fires at least once; the OS will further limit display frequency.

---

## Code Examples

Verified patterns from source code audit and official documentation:

### Existing `_checkRateAppPrompt` in game_page.dart (already correct)

```dart
// lib/features/game/presentation/pages/game_page.dart:625
void _checkRateAppPrompt(int stars) {
  final rateService = sl<RateAppService>();
  rateService.recordLevelCompleted(stars: stars);
  if (rateService.shouldPromptForReview()) {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) rateService.requestReview();
    });
  }
}
```

This is already called from `_trackAchievements()`. UX-03 is **already functionally implemented**. The 2-second delay is appropriate. No code change required unless timing needs adjustment. Verification task: confirm `_checkRateAppPrompt` is indeed called in `_trackAchievements` and that `RateAppService.shouldPromptForReview()` threshold (5 levels first, 15 thereafter) is acceptable per requirements.

### Existing `AdService.onLevelCompleted()` — needs modification

```dart
// CURRENT (lib/core/services/ad_service.dart:47):
void onLevelCompleted() {
  if (!_initialized) return;
  _levelsCompletedSinceAd++;
  if (_levelsCompletedSinceAd >= 3) {  // hardcoded — must change
    showInterstitial();
    _levelsCompletedSinceAd = 0;
  }
}

// REQUIRED SIGNATURE:
void onLevelCompleted({required bool isPremium}) {
  if (!_initialized || isPremium) return;
  _levelsCompletedSinceAd++;
  final threshold = sl<RemoteConfigService>().adFrequencyLevelCount;
  if (_levelsCompletedSinceAd >= threshold) {
    showInterstitial();
    _levelsCompletedSinceAd = 0;
  }
}
```

**Call site in game_page.dart line 672:**
```dart
// CURRENT:
sl<AdService>().onLevelCompleted();

// REQUIRED:
final authState = context.read<AuthBloc>().state;
final isPremium = authState is AuthAuthenticated && authState.user.isPremium;
sl<AdService>().onLevelCompleted(isPremium: isPremium);
```

### Share image capture flow (new)

```dart
// In LevelCompleteDialog or a share helper:
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

final _shareCardKey = GlobalKey();

Future<void> _shareScore() async {
  await Future.delayed(Duration.zero); // ensure painted
  final boundary = _shareCardKey.currentContext!
      .findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/merge_quest_score.png');
  await file.writeAsBytes(pngBytes);

  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)]),
  );
}
```

### Share card widget (new — design at Claude's discretion)

```dart
// lib/features/game/presentation/widgets/share_score_card.dart
class ShareScoreCard extends StatelessWidget {
  final int score;
  final int highestTile;
  final int levelNumber;

  const ShareScoreCard({
    super.key,
    required this.score,
    required this.highestTile,
    required this.levelNumber,
  });

  @override
  Widget build(BuildContext context) {
    // Branded card with app name, score, tile, level
    // Uses AppColors, AppTypography — no external dependencies
    // Must be self-contained (no BLoC reads) to render off-screen
    return Container(...);
  }
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `Share.shareXFiles([file])` | `SharePlus.instance.share(ShareParams(files: [...]))` | share_plus v10 (2024) | Old API still works but shows deprecation warning; new API is required going forward |
| Hardcoded ad threshold | Remote config key | This phase | Enables server-side A/B testing of ad cadence post-launch |

**Deprecated/outdated:**
- `Share.shareXFiles()`: Works in share_plus 12 but emits deprecation. Use `SharePlus.instance.share()`.

---

## Open Questions

1. **Where to place `ShareScoreCard` in dialog widget tree**
   - What we know: The card must be in the widget tree before capture. The share button is inside the dialog.
   - What's unclear: Should the card be rendered inside the dialog (visible as a preview) or off-screen (invisible until capture)?
   - Recommendation: Render inline inside the dialog below the score section but above the buttons. This also serves as a visual preview for the user, improving perceived quality.

2. **Does daily challenge card need target tile and time remaining?**
   - What we know: D-04 says "Card shows today's challenge info (target tile, board size, time remaining)." The `Challenge` entity in `AchievementsLoaded.dailyChallenge` has `description` and `isCompleted` fields (confirmed from code). Whether it has `targetTile`, `boardSize`, and `timeRemaining` fields is unverified.
   - What's unclear: The `Challenge` domain entity fields beyond `description`, `isCompleted`, `id`.
   - Recommendation: Planner must read `lib/features/achievements/domain/entities/challenge.dart` before coding the card. If the entity lacks those fields, the card uses `challenge.description` only (already displayed in the existing card).

3. **Onboarding skip analytics: separate event or reuse `logTutorialCompleted`?**
   - What we know: The existing `_onTutorialComplete` fires `logTutorialCompleted`. Skipping is a different user action.
   - What's unclear: Whether the analytics team wants to distinguish skips.
   - Recommendation: Add `onSkip` callback to `TutorialOverlay` so `game_page.dart` can log a separate analytics event. Falls under Claude's discretion.

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| share_plus | UX-05 score sharing | Not yet (not in pubspec) | — | None — must add |
| in_app_review | UX-03 review prompt | Already installed | 2.0.10 (pubspec) / 2.0.11 (pub.dev latest) | — |
| path_provider | UX-05 temp file write | Already installed | 2.1.5 | — |
| Firebase Remote Config | UX-04 ad frequency | Already installed | 6.0.2 | Hardcoded default 3 (graceful fallback already implemented) |
| Flutter SDK | All | Already installed | Dart 3.10+ / Flutter 3.x | — |

**Missing dependencies with no fallback:**
- `share_plus` — must be added via `flutter pub add share_plus`

**Missing dependencies with fallback:**
- Firebase Remote Config: `RemoteConfigService` already null-checks `_remoteConfig`; if Firebase unavailable, ad frequency defaults to 3.

---

## Project Constraints (from CLAUDE.md)

| Constraint | Impact on Phase 4 |
|------------|-------------------|
| Flutter Clean Architecture — feature-based organization | `ShareScoreCard` widget goes under `lib/features/game/presentation/widgets/` |
| BLoC for state management | No new BLoCs needed; use existing `AchievementsBloc`, `AuthBloc` reads |
| GetIt (`sl<T>()`) for DI | `AdService`, `RateAppService`, `RemoteConfigService`, `OnboardingLocalDataSource` — all already registered in `di.dart` |
| `const` constructors wherever possible | `ShareScoreCard` data passed via constructor, all sub-widgets should be const where data is fixed |
| Widgets < 50 lines — extract when build exceeds this | `ShareScoreCard` design may exceed 50 lines; extract sub-components as needed |
| No commented-out code in commits | Remove any dead code produced during refactors |
| firebase is optional — offline mode must work | All Firebase-dependent paths (`RemoteConfigService`) must fall through to defaults gracefully |
| Handle errors explicitly, never swallow silently | `_shareScore()` should catch and show a `SnackBar` on failure (e.g., permission denied) |
| Organize by feature: `lib/features/<feature>/{data,domain,presentation}/` | `share_score_card.dart` is presentation layer within `game` feature |

---

## Validation Architecture

> `workflow.nyquist_validation` is explicitly `false` in `.planning/config.json` — this section is skipped.

---

## Sources

### Primary (HIGH confidence)
- Source code audit: `lib/core/services/ad_service.dart`, `rate_app_service.dart`, `remote_config_service.dart`, `lib/features/onboarding/`, `lib/features/home/presentation/pages/home_page.dart`, `lib/features/game/presentation/pages/game_page.dart`, `lib/features/game/presentation/widgets/level_complete_dialog.dart`, `game_over_dialog.dart`
- [Flutter official API: RenderRepaintBoundary.toImage](https://api.flutter.dev/flutter/rendering/RenderRepaintBoundary/toImage.html)
- [pub.dev: share_plus 12.0.1](https://pub.dev/packages/share_plus) — latest stable, API verified
- [pub.dev: in_app_review 2.0.11](https://pub.dev/packages/in_app_review) — platform limitations verified
- `pubspec.yaml` — confirmed installed packages and versions

### Secondary (MEDIUM confidence)
- [share_plus versions page](https://pub.dev/packages/share_plus/versions) — version 12.0.1 confirmed current
- [RevenueCat Flutter docs](https://www.revenuecat.com/docs/getting-started/installation/flutter) — subscription status pattern (not directly used; premium sourced from `AppUser.isPremium` in `AuthBloc`)

### Tertiary (LOW confidence)
- WebSearch results on RepaintBoundary pitfalls (2025) — corroborates "must be painted" constraint; not verified against specific Flutter version in use

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — packages confirmed via pub.dev; existing stack confirmed via pubspec.yaml + source
- Architecture: HIGH — all integration points confirmed by direct code audit
- Pitfalls: HIGH (first-frame capture, premium guard) / MEDIUM (layout shift details)

**Research date:** 2026-03-26
**Valid until:** 2026-04-25 (share_plus API stable; in_app_review platform constraints stable)

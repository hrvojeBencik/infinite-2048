# Phase 4: UX Flow and Usability - Context

**Gathered:** 2026-03-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Make key engagement surfaces accessible and intuitive: add skip button to onboarding tutorial, surface daily challenge as a prominent card on the home screen, add review prompt after level complete, cap ad frequency for free users (premium never sees interstitials), and enable score sharing as a styled image via native share sheet. No architectural or animation changes.

</domain>

<decisions>
## Implementation Decisions

### Onboarding Skip (UX-01)
- **D-01:** Skip button visible immediately from the first tutorial step — a "Skip" text button in the top-right corner of the `TutorialOverlay`.
- **D-02:** Tapping skip dismisses the overlay and marks onboarding as complete via `OnboardingLocalDataSource`. Returning users never see the tutorial again.

### Daily Challenge on Home (UX-02)
- **D-03:** Prominent styled card at the top of the home screen, above the main menu options.
- **D-04:** Card shows today's challenge info (target tile, board size, time remaining). Tapping launches the daily challenge game. If already completed today, shows a checkmark/completed state.

### Review Prompt (UX-03)
- **D-05:** Review prompt fires after level complete using the existing `RateAppService`. Respects OS frequency limits (iOS only shows once per app version, Android respects Play quota).

### Ad Frequency (UX-04)
- **D-06:** Ad frequency defaults to every 3 levels, configurable via remote config. Premium (subscription) users never see interstitials.

### Score Sharing (UX-05)
- **D-07:** Add `share_plus` package to pubspec.yaml.
- **D-08:** Share button appears on both the level complete dialog and game over dialog.
- **D-09:** Shared image is a styled branded card rendered as a widget, captured via `RepaintBoundary` + `RenderRepaintBoundary.toImage()`. Card contains: score, highest tile reached, level number, and app name/logo.
- **D-10:** Share via native share sheet using `Share.shareXFiles()` with the rendered image.

### Claude's Discretion
- Daily challenge card visual design and layout
- Share card visual design (colors, typography, layout)
- Ad frequency remote config key name
- Review prompt timing (immediate after dialog or delayed)
- Whether to use `in_app_review` directly or wrap through RateAppService

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Onboarding
- `lib/features/onboarding/presentation/widgets/tutorial_overlay.dart` — Tutorial overlay widget. Add skip button here.
- `lib/features/onboarding/data/datasources/onboarding_local_datasource.dart` — Marks onboarding complete.

### Home & Daily Challenge
- `lib/features/home/presentation/pages/home_page.dart` — Home page. Add daily challenge card here.
- `lib/features/achievements/presentation/bloc/achievements_bloc.dart` — Daily challenge logic lives here.

### Review & Ads
- `lib/core/services/rate_app_service.dart` — Existing rate app service.
- `lib/core/services/ad_service.dart` — Ad service with interstitial logic. Cap frequency here.
- `lib/core/services/remote_config_service.dart` — Remote config for ad frequency.

### Game dialogs (share button integration)
- `lib/features/game/presentation/widgets/level_complete_dialog.dart` — Add share button + capture widget.
- `lib/features/game/presentation/widgets/game_over_dialog.dart` — Add share button.
- `lib/features/game/presentation/pages/game_page.dart` — BlocListener handles dialog triggers.

### DI
- `lib/app/di.dart` — Register any new services.

### Project planning
- `.planning/REQUIREMENTS.md` — UX-01 through UX-05 are this phase's requirements

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **RateAppService**: Already exists and is registered in DI. May just need wiring into level complete flow.
- **AdService**: Already has interstitial logic. Frequency cap may already be partially implemented.
- **OnboardingLocalDataSource**: Has methods to mark onboarding complete. Skip button calls this.
- **AchievementsBloc**: Already handles daily challenge state — home page card reads from this.
- **RemoteConfigService**: Existing remote config integration for dynamic values.

### Established Patterns
- **Dialogs**: Level complete and game over now use `showGeneralDialog` with slide-up (Phase 3).
- **BlocListener**: Side effects (analytics, haptic, dialogs) handled in game_page.dart BlocListener.
- **RepaintBoundary**: Already used for render isolation (Phase 2) — same pattern for share image capture.

### Integration Points
- **home_page.dart**: Daily challenge card goes above existing menu.
- **level_complete_dialog.dart**: Share button + review prompt integration.
- **game_over_dialog.dart**: Share button integration.
- **tutorial_overlay.dart**: Skip button in top-right corner.

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard Flutter patterns for share, review, and onboarding UX.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 04-ux-flow-and-usability*
*Context gathered: 2026-03-26*

# Phase 3: Animations and Visual Polish - Context

**Gathered:** 2026-03-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Add visual polish and animation feedback to every core interaction: tune the existing merge animation and block swipes during it, add consistent screen transitions (fade+slide lateral, slide-up modal), fire confetti on level complete, configure native splash screen, and ensure haptic feedback fires on merge. This phase builds on the stabilized architecture from Phase 2 — no architectural changes.

</domain>

<decisions>
## Implementation Decisions

### Merge Animation (ANIM-01)
- **D-01:** Keep the existing TileWidget scale-pop animation (400ms, 0.85→1.18→0.95→1.0, easeOutCubic). Do not change the curve or timing.
- **D-02:** Add swipe input blocking during the merge animation. Swipes must not register while the animation is playing. This is the key fix — the animation already exists but swipes can fire mid-animation.

### Screen Transitions (ANIM-02)
- **D-03:** Lateral navigation keeps the existing fade + slight slide-right (300ms, `_buildTransitionPage()`). No changes needed.
- **D-04:** Full-screen modals (level complete dialog, game over dialog) switch to slide-up from bottom transition. Currently using `showDialog()` default — replace with custom slide-up.

### Haptic Feedback on Merge (ANIM-03)
- **D-05:** Haptic feedback fires on tile merge events via `sl<HapticService>()`. HapticService is already extracted and in DI from Phase 2. Wire merge haptic in the GameBloc listener or the TileWidget merge animation trigger.

### Confetti Celebration (ANIM-04)
- **D-06:** Add the `confetti` package to pubspec.yaml.
- **D-07:** Confetti burst fires from the top of the screen when the level complete dialog appears. 2-3 second duration, then fades. Fires only on level complete — not on achievements or other events.

### XP Bar Animation (ANIM-05)
- **D-08:** XP bar animates smoothly on XP gain. Claude has discretion on implementation approach (AnimatedContainer, TweenAnimationBuilder, or custom AnimationController).

### Particle Effects (ANIM-06)
- **D-09:** ParticleEffect widget already exists. Claude has discretion on polishing — ensure consistent visual style with the rest of the animations. No major rework.

### Native Splash Screen (ANIM-07)
- **D-10:** Add `flutter_native_splash` package to pubspec.yaml (dev dependency).
- **D-11:** Splash screen shows the app icon centered on the app's dark background color (`AppColors.background`). No gradient. Matches the app's dark theme for seamless transition to home screen.

### Claude's Discretion
- XP bar animation approach (ANIM-05)
- Particle effect polish details (ANIM-06)
- Exact confetti configuration (particle count, colors, blast direction)
- Whether to use `ConfettiController` inline or extract to a reusable widget
- Haptic feedback timing relative to animation
- Swipe blocking implementation (AnimationController status check vs. flag in GameBloc)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Animation source files
- `lib/features/game/presentation/widgets/tile_widget.dart` — Existing merge/spawn/glow AnimationControllers. ANIM-01 tuning target. Merge animation at lines 48-59 (scale-pop TweenSequence).
- `lib/features/game/presentation/widgets/particle_effects.dart` — Existing ParticleEffect widget. ANIM-06 polish target.
- `lib/features/game/presentation/widgets/level_complete_dialog.dart` — Level complete dialog. ANIM-04 confetti integration point.
- `lib/features/game/presentation/widgets/game_over_dialog.dart` — Game over dialog. Transition change target (ANIM-02).
- `lib/features/game/presentation/widgets/score_display.dart` — Score display with animations. Nearby XP bar location (ANIM-05).

### Navigation
- `lib/app/router.dart` — `_buildTransitionPage()` at lines 34-61. All GoRoute pageBuilders reference this. ANIM-02 transition changes happen here.

### Haptic & services
- `lib/core/services/haptic_service.dart` — Extracted in Phase 2. Access via `sl<HapticService>()`. ANIM-03 integration.
- `lib/app/di.dart` — DI registrations. New packages (confetti) don't need DI but verify no conflicts.

### Game page (respect Phase 2 boundaries)
- `lib/features/game/presentation/pages/game_page.dart` — BlocListener + targeted BlocBuilders with RepaintBoundary zones. Animations must not break rebuild boundaries.

### Project planning
- `.planning/REQUIREMENTS.md` — ANIM-01 through ANIM-07 are this phase's requirements
- `.planning/phases/02-architectural-foundations/02-CONTEXT.md` — Phase 2 decisions (HapticService DI, BlocBuilder zones)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **TileWidget AnimationControllers**: 3 existing controllers (merge, spawn, glow) with TweenSequence animations. Merge animation already has the right feel — just needs swipe blocking.
- **_buildTransitionPage()**: Shared transition helper in router.dart. Can be extended or a second helper created for modal transitions.
- **ParticleEffect widget**: Exists and is used in game page Stack. Polish, don't rewrite.
- **HapticService**: Fully extracted with DI from Phase 2. Ready for merge haptic integration.
- **AnimatedButton widget**: Exists in `lib/core/widgets/animated_button.dart`. May be reusable for celebration animations.

### Established Patterns
- **CustomTransitionPage**: go_router pattern for custom transitions. All routes use it via `_buildTransitionPage()`.
- **BlocListener for side effects**: Game page uses BlocListener for analytics, dialogs, juice effects. Confetti and haptic merge events should integrate here.
- **RepaintBoundary zones**: Game page has 4 zones. New animations in the board zone stay inside its boundary.

### Integration Points
- **Level complete trigger**: BlocListener in game_page.dart handles `GameWon` state — confetti fires here.
- **Merge trigger**: `_triggerJuiceEffects()` in game_page.dart — haptic merge fires here.
- **Router transitions**: `_buildTransitionPage()` is the single point for all route transitions.
- **pubspec.yaml**: New dependencies: `confetti` (runtime), `flutter_native_splash` (dev).

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard Flutter animation patterns. Keep the app's existing dark theme aesthetic.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 03-animations-and-visual-polish*
*Context gathered: 2026-03-26*

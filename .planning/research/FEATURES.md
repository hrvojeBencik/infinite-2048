# Feature Research

**Domain:** Mobile puzzle game — polish, optimization, and store preparation
**Researched:** 2026-03-25
**Confidence:** HIGH (store requirements from official sources), MEDIUM (polish patterns from community consensus + competitor analysis)

---

## Context

This is a v1.2 milestone for an existing app. All gameplay features are built. The question is: what does "launch-ready" mean in practice for a mobile puzzle game in 2025/2026? This research covers three domains:

1. **Game feel & polish** — what makes a puzzle game feel premium
2. **Performance baseline** — what players expect technically
3. **Store preparation** — what App Store and Google Play require for submission

---

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete, gets 1-star reviews.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Smooth 60fps tile animations | Every top competitor has fluid merge animations; stuttering feels broken | MEDIUM | Use Flutter Impeller (default iOS, opt-in Android); avoid rebuilding unrelated widgets during animation |
| Merge animation + particle burst | Standard in every tile/match game; absence feels unfinished | MEDIUM | Scale + fade + particle spray on merge; 150–300ms total; use `flutter_particles` or custom Canvas |
| Screen transition animations | Jarring cuts between screens signal low quality | LOW | Shared element transitions or simple fade/slide; go_router supports custom page transitions |
| Satisfying merge sound | Audio feedback on merge is universal table-stakes | LOW | Already have SoundService; ensure merge SFX is distinct, punchy, short (<200ms) |
| Haptic feedback on tile merge | Standard on iOS since 2019; Android too; users notice absence | LOW | `HapticFeedback.mediumImpact()` on merge; `lightImpact` on tile slide; Flutter has built-in support |
| No visible jank on game board | Frame drops during swipe = broken feel for core mechanic | MEDIUM | Profile with Flutter DevTools; isolate game logic from render thread if needed |
| Fast app startup | Users abandon if >3s to interactive; puzzle games open frequently | MEDIUM | Defer non-critical init (analytics, remote config) post-first-frame; lazy-load Hive boxes |
| Clear undo behavior (or no undo) | Users need to know if undo exists and what it costs | LOW | If undo is premium, paywall must be clear; if no undo, don't show phantom button |
| Legible tile typography at all sizes | Tiles with 4+ digit numbers must be readable | LOW | Dynamic font sizing in tile widgets; test on small screens (iPhone SE) |
| App icon that communicates the game | App store icon is first impression; tile/number theme expected | LOW | Icon must work at 1024x1024 (no alpha for iOS) and at 48dp (Android launcher) |
| Privacy policy URL | Required by both stores before submission | LOW | Already added to GitHub Pages; ensure URL is live and accessible |
| Crash-free session rate >99% | Stores penalize crashy apps; users leave 1-star reviews | MEDIUM | Firebase Crashlytics (already integrated); fix any known crash paths before submission |

### Differentiators (Competitive Advantage)

Features that go beyond the field. The 2048 space is saturated — these are how "Merge Quest" earns its identity.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Tile merge "juice" celebration | Level-up moments (big merges, zone completion) should feel spectacular — confetti, screen flash, XP burst animation | MEDIUM | Trigger on 1024+, 2048, zone completion; layered: particle burst + scale pop + sound + haptic + XP counter animation |
| Zone transition ceremony | Moving to a new zone is a milestone; deserves its own animated reveal | MEDIUM | Full-screen takeover with zone name, thematic color wash, unlock animation; ~2s skippable |
| Animated XP bar + level-up flash | Visible XP gain after each move/level makes progression feel alive | LOW | Already have XP system; add number counter animation + bar fill animation on XP gain |
| Per-tile unlock reveal animation | New tile themes should feel earned; a quick "unlocked" animation retains novelty | LOW | Single-frame overlay with shimmer/glow + "New theme unlocked!" toast |
| Difficulty curve visual cues | Premium puzzle games telegraph hard sections upfront — "Zone 3: Hard" with visual treatment | LOW | Badge or difficulty icon on level cards; reduces frustration by setting expectations |
| Daily challenge entry point on home | Top-performing puzzle games put daily content front-and-center | LOW | Already have daily challenges; surface them as a persistent card/banner on home screen |
| Contextual empty states | First launch, no achievements yet, no leaderboard data — these screens need warmth | LOW | "No achievements yet — complete your first level!" instead of blank lists |
| Onboarding skip + revisit | Power users hate forced tutorials; casual users want help later | LOW | "Skip" button on tutorial with "Revisit in Settings" — already have onboarding; add skip |
| Colorblind mode | ~8% of males have some colorblindness; tile color reliance without number would break the game | MEDIUM | High-contrast tile palette option in settings; deuteranopia-safe color ramp is sufficient |
| Localization placeholder | Even single-locale apps should externalize strings before store launch for future expansion | HIGH | Deferred to future milestone — high complexity, not launch-blocking |

### Anti-Features (Commonly Requested, Often Problematic)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Interstitial ads after every level | Maximizes ad impressions per session | Puzzle games have high session frequency — forcing ads every level is the #1 reason for uninstalls and 1-star reviews in the genre | Show rewarded ads (opt-in) + interstitials only after X levels (remote config threshold, not every level) |
| Dark mode as a separate full theme | Users request it; seems like polish | In a game, "dark mode" means rebuilding the entire color system — very high effort for marginal retention gain when the game already has tile themes | Offer a "Night" tile theme as a premium theme instead; satisfies the request at lower cost |
| Undo button always visible | Looks premium, matches web 2048 | If undo is premium/paywalled, a permanently visible disabled button creates friction and confusion | Show undo only when the feature is available (premium unlocked or rewarded ad watched); hide otherwise |
| Social sharing screenshots | Viral loop potential | Deep linking, dynamic image generation, share sheets — significant complexity for unproven return in puzzle genre | Defer to v2; focus on review prompt instead which has measurable impact on discovery |
| Animated background / parallax tiles | Visually impressive in screenshots | Constant background animation increases GPU load, worsens battery life, and distracts from the core board — kills game feel | Static themed backgrounds with subtle texture; animate only on events (level complete) |
| In-app chat / friend system | Community feature | Requires backend, moderation, privacy handling — massive scope for a game that runs offline-first | Leaderboard is sufficient social proof; friend system is v3+ |

---

## Feature Dependencies

```
Store submission
    └──requires──> App icon (1024x1024, no alpha for iOS)
    └──requires──> Screenshots (6.9" iPhone + 13" iPad for iOS; 2 minimum for Android)
    └──requires──> Privacy policy URL (live, accessible)
    └──requires──> Crash-free rate >99% (Firebase Crashlytics reporting)
    └──requires──> Age rating questionnaire completed in console

Tile merge "juice"
    └──requires──> Merge animation (scale/fade)
    └──requires──> Sound (already built)
    └──requires──> Haptic (HapticFeedback API)
    └──enhances──> XP bar animation (stacks with merge celebration)

Zone transition ceremony
    └──requires──> Zone unlock logic (already built)
    └──enhances──> Tile theme unlock reveal (similar layered animation pattern)

Daily challenge home card
    └──requires──> Daily challenge system (already built)
    └──enhances──> Home screen engagement (reduces churn)

Review prompt
    └──requires──> Positive session signal (level complete, streak milestone)
    └──conflicts──> Mid-gameplay prompts (never interrupt play)
```

### Dependency Notes

- **Store submission requires app icon:** The 1024x1024 iOS icon with no alpha channel is non-negotiable — App Store Connect rejects submissions without it. Android requires adaptive icon (foreground + background layers).
- **Crash-free rate requirement:** Firebase Crashlytics is already integrated but must be confirmed reporting. A crash-free session rate below 99% in the first 7 days can trigger Play Store "bad quality" flags.
- **Merge juice requires animation first:** Haptics and particles are meaningless without the base merge animation being smooth. Establish 60fps tile movement before adding effects.
- **Daily challenge card enhances retention:** The challenge system is built but surfacing it on home screen is the highest-leverage single change for day-7 retention without new feature work.

---

## MVP Definition

### Launch With (v1.2 — this milestone)

- [ ] App icon (1024x1024 iOS, adaptive Android) — store submission blocked without it
- [ ] App Store screenshots: 6.9" iPhone set (5–8 screens showing gameplay, zones, progression) — required
- [ ] Google Play screenshots: phone set (minimum 2, recommended 5–8) — required
- [ ] Store listing copy: title, subtitle, description, keywords — required for discovery
- [ ] Privacy policy accessible at live URL — both stores require this
- [ ] Merge animation (scale pop + fade out on source tile) — core game feel
- [ ] Haptic feedback on merge and tile slide — iOS/Android standard
- [ ] Smooth screen transitions (fade or slide, no jarring cuts) — basic polish
- [ ] Startup time under 3 seconds to interactive — user retention baseline
- [ ] Crash-free rate confirmed via Crashlytics before submission — store health
- [ ] Review prompt after level completion (positive moment, 3x/year limit) — ratings strategy
- [ ] Onboarding skip button — respects returning users

### Add After Validation (v1.x)

- [ ] Zone transition ceremony — needs animation infrastructure from v1.2 first; high impact but medium effort
- [ ] Merge "juice" particle burst — layered on top of base animation; add after confirming 60fps baseline
- [ ] Daily challenge home screen card — high-leverage retention; ship in first update post-launch
- [ ] Animated XP bar gain — visible progression feel; quick win after launch stabilizes
- [ ] Contextual empty states — polish pass after first reviews identify friction points

### Future Consideration (v2+)

- [ ] Colorblind mode — valid accessibility need; deferred due to color system complexity
- [ ] Localization — high effort; validate en-only market first
- [ ] Social sharing / deep links — unproven ROI in genre; requires backend work
- [ ] Per-tile unlock reveal animation — nice-to-have theming polish

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| App icon + store screenshots | HIGH | LOW | P1 |
| Store listing copy + keywords | HIGH | LOW | P1 |
| Crash-free confirmation (Crashlytics) | HIGH | LOW | P1 |
| Merge animation (scale/fade) | HIGH | MEDIUM | P1 |
| Haptic feedback on merge | HIGH | LOW | P1 |
| App startup time optimization | HIGH | MEDIUM | P1 |
| Screen transition animations | MEDIUM | LOW | P1 |
| Review prompt (post level-complete) | HIGH | LOW | P1 |
| Onboarding skip button | MEDIUM | LOW | P1 |
| Zone transition ceremony | HIGH | MEDIUM | P2 |
| Merge particle burst | MEDIUM | MEDIUM | P2 |
| Daily challenge home card | HIGH | LOW | P2 |
| Animated XP bar | MEDIUM | LOW | P2 |
| Contextual empty states | MEDIUM | LOW | P2 |
| Colorblind mode | MEDIUM | HIGH | P3 |
| Localization | HIGH | HIGH | P3 |
| Social sharing | LOW | HIGH | P3 |

**Priority key:**
- P1: Must have for v1.2 launch
- P2: Ship in first post-launch update
- P3: Future milestone

---

## Competitor Feature Analysis

Competitors analyzed: 2048 (Ketchapp), 2248: Number Puzzle 2048, 2048 Pro (Playsquare), 2248 Master.

| Feature | 2248: Number Puzzle | 2048 Pro (Playsquare) | Our Approach |
|---------|---------------------|----------------------|--------------|
| Merge animation | Satisfying number-pop + particles | Smooth tile slide | Scale pop on spawn point + particle spray |
| Sound on merge | Satisfying tone per number level | Present, subtle | Already built; ensure merge tone scales with tile value (higher = deeper/different) |
| Level progression | Zone-based with visual themes | Classic board only | Already differentiated with zones + special tiles |
| Daily content | Daily puzzle | No | Already built; needs home screen surfacing |
| Haptics | Present | Present | Must add — standard |
| Colorblind support | Not found | Not found | Opportunity to differentiate with future investment |
| App Store screenshots | Gameplay + feature callouts | Gameplay only | Gameplay + zone themes + achievement + "special tiles" callout frame |
| Review prompt | After milestone moments | After session | After level complete + streak milestone |

---

## Store Preparation Specifics

### iOS App Store Requirements (HIGH confidence — official Apple docs)

- **Primary screenshot size:** 6.9-inch (1290 x 2796px or 1320 x 2868px) — required; auto-scales to smaller devices
- **iPad:** 13-inch (2064 x 2752px) — required if iPad is supported target
- **Format:** PNG (preferred) or JPEG; no alpha; max 10 per localization; max 10MB each
- **Preview video:** Optional; 30–120 seconds; hosted on YouTube (public or unlisted)
- **App icon:** 1024x1024px PNG, no alpha, no rounded corners (App Store applies mask)
- **Metadata:** Title (30 chars), Subtitle (30 chars), Description (4000 chars), Keywords (100 chars)
- **Privacy policy:** Required URL field in App Store Connect

### Google Play Requirements (HIGH confidence — official Play Console docs)

- **Screenshots:** Minimum 2, recommended 5–8; JPEG or 24-bit PNG (no alpha); 16:9 or 9:16 aspect ratio; min 320px per side, max 3840px; max 8MB each
- **Feature graphic:** 1024 x 500px — used in Play Store editorial; required for featuring consideration
- **App icon:** 512 x 512px PNG with transparency; separate from in-app adaptive icon
- **Preview video:** YouTube URL; optional
- **Metadata:** Title (50 chars), Short description (80 chars), Full description (4000 chars)
- **Privacy policy:** Required URL in Play Console

### Screenshot Content Strategy

Best-performing puzzle game screenshots follow this pattern:
1. Screen 1: Core gameplay (the board mid-game, clear tile values) — establishes genre immediately
2. Screen 2: Special mechanic differentiator (bomb/wildcard tile in action, or zone theme)
3. Screen 3: Progression/achievement (zone selection, player level, achievement unlocked)
4. Screen 4: Social proof / leaderboard or challenge completion
5. Screen 5: Premium feature (tile theme customization or endless mode)

Add short text callout overlays on each screenshot (e.g., "Unlock new zones", "Special tiles change everything"). These outperform screenshot-only in A/B tests across the genre.

---

## Sources

- [Apple Screenshot Specifications — App Store Connect](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/) — HIGH confidence
- [Google Play Store Listing Best Practices — Play Console Help](https://support.google.com/googleplay/android-developer/answer/13393723) — HIGH confidence
- [Google Play Screenshot Sizes — AppRadar](https://appradar.com/blog/android-app-screenshot-sizes-and-guidelines-for-google-play) — MEDIUM confidence
- [Flutter Performance Optimization 2025 — ITNEXT](https://itnext.io/flutter-performance-optimization-10-techniques-that-actually-work-in-2025-4def9e5bbd2d) — MEDIUM confidence
- [Flutter 2025 Performance Best Practices — Flutterexperts](https://flutterexperts.com/flutter-2025-performance-best-practices-what-has-changed-what-still-works/) — MEDIUM confidence
- [Haptics in Mobile UX 2025 — Saropa/Medium](https://saropa-contacts.medium.com/2025-guide-to-haptics-enhancing-mobile-ux-with-tactile-feedback-676dd5937774) — MEDIUM confidence
- [Game Juice Design — The Design Lab](https://thedesignlab.blog/2025/01/06/making-gameplay-irresistibly-satisfying-using-game-juice/) — MEDIUM confidence
- [Rating Prompt Best Practices — Appbot](https://appbot.co/blog/prompting-for-ratings-prompt-early-or-wait/) — MEDIUM confidence
- [Hybrid-Casual Puzzle UX Patterns — Deconstructor of Fun](https://www.deconstructoroffun.com/blog/2025/2/3/hybridcasual-puzzles-expanding-the-puzzle-market) — MEDIUM confidence
- Competitor app store listings analyzed: 2248 Number Puzzle 2048, 2048 Pro (Playsquare), 2048 by Ketchapp — LOW-MEDIUM confidence (screenshots observed, not tested)

---

*Feature research for: 2048: Merge Quest — v1.2 Polish & Store Preparation*
*Researched: 2026-03-25*

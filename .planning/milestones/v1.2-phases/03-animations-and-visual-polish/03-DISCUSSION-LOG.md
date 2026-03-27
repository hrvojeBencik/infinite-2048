# Phase 3: Animations and Visual Polish - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-26
**Phase:** 03-animations-and-visual-polish
**Areas discussed:** Merge animation tuning, Screen transition style, Confetti & celebrations, Native splash & cold start

---

## Merge Animation Tuning

| Option | Description | Selected |
|--------|-------------|----------|
| Keep current, ensure timing (Recommended) | Existing scale-pop is good, just block swipes during animation | ✓ |
| Refine the curve | Adjust scale values and easing | |
| You decide | Claude tunes the animation | |

**User's choice:** Keep current, ensure timing

---

## Screen Transition Style

| Option | Description | Selected |
|--------|-------------|----------|
| Slide-up for modals (Recommended) | Lateral keeps fade+slide, modals use slide-up from bottom | ✓ |
| Keep everything as-is | Existing transitions work for everything | |
| You decide | Claude picks per route type | |

**User's choice:** Slide-up for modals

---

## Confetti & Celebrations

| Option | Description | Selected |
|--------|-------------|----------|
| Burst from top, 2-3 seconds (Recommended) | Confetti blast from top on level complete, then fades | ✓ |
| Center explosion | Confetti explodes outward from center | |
| You decide | Claude picks style and timing | |

**User's choice:** Burst from top, 2-3 seconds

---

## Native Splash & Cold Start

| Option | Description | Selected |
|--------|-------------|----------|
| App icon on dark background (Recommended) | Centered icon on AppColors.background, seamless transition | ✓ |
| Gradient background | Icon on AppColors.backgroundGradient | |
| You decide | Claude designs to match app style | |

**User's choice:** App icon on dark background

---

## Claude's Discretion

- XP bar animation approach
- Particle effect polish details
- Confetti configuration (particle count, colors, blast direction)
- Haptic feedback timing relative to animation
- Swipe blocking implementation approach

## Deferred Ideas

None — discussion stayed within phase scope.

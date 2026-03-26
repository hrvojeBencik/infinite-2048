# Phase 5: Store Preparation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-26
**Phase:** 05-store-preparation
**Areas discussed:** App icon strategy, Screenshot pipeline, Store listing copy, Privacy & compliance

---

## App Icon Strategy

### Icon Source

| Option | Description | Selected |
|--------|-------------|----------|
| I have a custom icon | Designed icon ready to use — needs sizing and adaptive layers | ✓ |
| Current icon is custom | Existing 1024x1024 IS the designed icon | |
| Need icon designed | No custom icon yet | |

**User's choice:** Has a custom icon to provide
**Notes:** Will provide the source PNG later during execution

### Adaptive Icon Background

| Option | Description | Selected |
|--------|-------------|----------|
| Solid color background | Single brand color behind foreground icon | ✓ |
| Gradient background | Gradient layer for visual depth | |
| You decide | Claude picks from existing theme | |

**User's choice:** Solid color background

### Icon Generation Tool

| Option | Description | Selected |
|--------|-------------|----------|
| flutter_launcher_icons | Flutter package — generates all sizes from single source PNG | ✓ |
| Manual export | User provides pre-sized PNGs | |

**User's choice:** flutter_launcher_icons

### Icon File Location

| Option | Description | Selected |
|--------|-------------|----------|
| I'll provide it later | Drop source PNG into project before running generator | ✓ |
| It's already in the project | File already in repo | |

**User's choice:** Will provide later

---

## Screenshot Pipeline

### Capture Method

| Option | Description | Selected |
|--------|-------------|----------|
| Fastlane + integration tests | Automated pipeline | |
| Manual screenshots | Take screenshots on simulators/devices manually | ✓ |
| Fastlane snapshot only | Fastlane captures without integration tests | |

**User's choice:** Manual screenshots

### Fastlane Usage

| Option | Description | Selected |
|--------|-------------|----------|
| Skip fastlane entirely | Upload directly through store consoles | ✓ |
| Fastlane for framing only | Use frameit for device frames/captions | |
| Fastlane for delivery only | Use deliver/supply for CLI uploads | |

**User's choice:** Skip fastlane entirely
**Notes:** STORE-08 (fastlane pipeline) descoped from this phase

### Screenshot Scenes

| Option | Description | Selected |
|--------|-------------|----------|
| Gameplay (active board) | Mid-game board showing tiles and score | ✓ |
| Level select / zones | Zone map or level selection | ✓ |
| Home screen | Main menu with daily challenge | |
| Level complete / achievements | Victory screen with confetti | ✓ |

**User's choice:** Gameplay, Level select/zones, Level complete/achievements (3 of 4)

---

## Store Listing Copy

### App Name

| Option | Description | Selected |
|--------|-------------|----------|
| 2048: Merge Quest | Current working title with keyword | ✓ |
| Infinite 2048 | Project name — endless/progression focus | |
| Something else | Different name | |

**User's choice:** 2048: Merge Quest

### Description Tone

| Option | Description | Selected |
|--------|-------------|----------|
| Casual & fun | Playful, emoji-friendly, casual gamers | ✓ |
| Clean & minimal | Straightforward, no fluff | |
| Competitive & challenging | Strategy, skill, progression emphasis | |

**User's choice:** Casual & fun

### ASO Approach

| Option | Description | Selected |
|--------|-------------|----------|
| Use /aso-expert | Skill analyzes codebase and generates optimized listings | ✓ |
| Write manually | Claude writes based on discussion | |

**User's choice:** Use /aso-expert skill

### Category

| Option | Description | Selected |
|--------|-------------|----------|
| Games > Puzzle | Primary fit for 2048 genre | ✓ |
| Games > Board | Alternative for grid-based games | |
| Games > Strategy | Emphasizes thinking/planning | |

**User's choice:** Games > Puzzle

---

## Privacy & Compliance

### Data Collection

| Option | Description | Selected |
|--------|-------------|----------|
| No extra collection | Only Firebase Analytics + AdMob automatic collection | ✓ |
| Firebase Auth collects identity | Google/Apple sign-in stores email/name | |
| Not sure | Need code audit | |

**User's choice:** No extra collection beyond Firebase Analytics and AdMob

### Paywall Implementation

| Option | Description | Selected |
|--------|-------------|----------|
| RevenueCat native paywall | Pre-built UI handles compliance | |
| Custom Flutter paywall | Custom-built paywall screen | ✓ |
| Not sure | Need to check codebase | |

**User's choice:** Custom Flutter paywall — needs 3.1.2 compliance audit

### Google Play Account

| Option | Description | Selected |
|--------|-------------|----------|
| Yes, personal account | 14-day closed testing gate applies | ✓ |
| Yes, organization account | Different requirements | |
| Not yet | Need to create | |

**User's choice:** Personal account — 14-day gate confirmed

---

## Claude's Discretion

- Adaptive icon background color (from AppColors)
- PrivacyInfo.xcprivacy exact API declarations
- Data Safety form field mapping
- Screenshot styling
- Paywall compliance fix implementation

## Deferred Ideas

- STORE-08 (Fastlane pipeline) — descoped, manual workflow for v1.2

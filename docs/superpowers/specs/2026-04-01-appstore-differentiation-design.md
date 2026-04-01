# App Store Differentiation Design — Merge Quest

**Date:** 2026-04-01
**Goal:** Pass Apple App Store review by differentiating from generic 2048 clones
**Approach:** Branding + Visual Differentiation (Approach 2)
**Timeline:** ASAP — minimal but high-impact changes

---

## Context

The app was rejected by Apple for being too similar to other 2048 apps ("similar binary, metadata, and/or concept"). The app has genuine differentiators (5 special tile types, 5 zones, 50 hand-crafted levels, daily/weekly challenges) but presents too similarly to generic 2048 clones in branding, tile visuals, and home screen layout.

---

## Section 1: Rebranding

### App Name
- **iOS display name**: "Merge Quest" (was "2048: Merge Quest")
- **iOS subtitle**: "Zones, Special Tiles & Daily Fun"
- **Android label**: "Merge Quest"

### Home Screen Header
Change from:
```
MERGE QUEST (small)
2048 (huge 44px)
```
To:
```
MERGE QUEST (huge, hero text)
The Ultimate Number Puzzle (small tagline)
```

### App Store Metadata
- **Description**: Opens with special tile mechanics and zone progression, NOT "a 2048 game"
- **Keywords**: Drop generic "puzzle, brain, merge" — add "zone, bomb tile, ice tile, daily puzzle, quest"
- **Promotional text**: "5 Zones. 5 Special Tiles. 50 Hand-Crafted Levels."

### Internal References
- Update `AppConstants` display name
- Update any in-app copy referencing "Infinite 2048" or "2048" as the game identity

---

## Section 2: Visual Tile Differentiation

### Special Tiles (currently just colored overlays on squares)

**Bomb tiles:**
- Bomb icon (💣) rendered above the number
- Pulsing glow animation in red/orange
- Slightly rounded hexagonal shape instead of square

**Ice tiles:**
- Cracked ice texture overlay
- Frosted border effect
- Snowflake icon indicator
- Number rendered in light blue

**Multiplier tiles:**
- Sparkle/star icon (✦)
- Golden shimmer animation
- Double border with gold gradient

**Wildcard tiles:**
- Rainbow gradient border that cycles colors
- "?" watermark behind the number
- Prismatic glow

**Blocker tiles:**
- Dark stone/rock texture
- No number displayed
- Cross-hatch pattern, visually "heavy"

### Regular Tiles
- Subtle gradient fills per value (instead of flat colors)
- Soft inner shadow for depth — less flat than original 2048 style

### Board Frame
- Zone-themed border around the game board (flame edges for Inferno, frost for Glacier, etc.)
- Subtle zone-colored ambient glow behind the board

---

## Section 3: Home Screen Redesign

### Layout (top to bottom)
1. **Hero section**: Large "MERGE QUEST" title with current zone's color theme as gradient backdrop. Zone progress indicator: "Zone 2: Inferno — Level 14/20" with visual progress bar in zone colors
2. **Current zone card**: Prominent card showing zone name, its special tile mechanic with icon preview (e.g., bomb icon for Inferno), and "Continue" button. Replaces generic "Play" button
3. **Daily/Weekly challenge cards**: Keep as-is (already good differentiators)
4. **Quick play row**: Endless mode + replay completed levels as secondary actions
5. **Bottom row**: Settings, achievements, leaderboard, profile — same as now

### Key Differences
- Home screen communicates "you're on a journey through zones" instead of "pick a mode"
- Current zone's identity (color, mechanic, icon) always visible
- First-time users immediately see special mechanics exist

### Implementation
- Rearrange existing widgets and update copy/styling in `home_page.dart`
- Data (zone, level, progress) already available from progression system
- No new data layer or BLoC changes needed

---

## Section 4: App Icon & Board Styling

### App Icon
- Replace current icon to emphasize "quest" identity
- Design concept: Stylized tile with bomb/explosion effect and zone-colored streaks, "MQ" monogram or single tile with special effect
- **User must provide/create actual icon image** — code will reference new asset path
- Spec for designer: 1024x1024, dark background (#0A0E21), prominent special tile effect, no "2048" text

### Game Board Styling
- Dark rounded board container with subtle zone-colored inner glow/border
- Grid lines get faint zone-colored tint instead of uniform gray
- Board background shifts per zone (deep red tint for Inferno, blue tint for Glacier, etc.)
- Cell empty-state gets soft inset shadow instead of flat dark squares

---

## Files to Modify

1. **Branding**: `Info.plist`, `AndroidManifest.xml`, `pubspec.yaml`, `lib/core/constants/app_constants.dart`
2. **Home screen**: `lib/features/home/presentation/pages/home_page.dart`, related widgets
3. **Tile visuals**: `lib/features/game/presentation/widgets/tile_widget.dart`, `lib/core/theme/` files
4. **Board styling**: `lib/features/game/presentation/widgets/board_widget.dart` (or equivalent)
5. **Metadata**: `STORE_LISTING.md`, any fastlane metadata files
6. **App icon config**: `flutter_launcher_icons` config or manual asset replacement

---

## Out of Scope
- New gameplay mechanics
- Hexagonal/circular tile shapes (too much effort for ASAP)
- Custom asset creation (icon must be provided by user)
- Sound/audio changes
- Backend changes

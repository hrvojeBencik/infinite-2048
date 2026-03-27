# Screenshot Capture Guide

## Overview

This guide provides exact device sizes, scene descriptions, and capture instructions for manually capturing App Store and Google Play screenshots. Screenshots are submitted raw (no device frames, no overlaid text) — both stores apply their own device frames for featured artwork.

---

## iOS — App Store Connect

### Required Sizes

| Label | Dimensions (Portrait) | Device/Simulator |
|-------|----------------------|-----------------|
| 6.9" display | 1260 x 2736 px | iPhone 16 Pro Max simulator |
| 6.5" display | 1284 x 2778 px OR 1242 x 2688 px | iPhone 15 Plus or iPhone 11 Pro Max simulator |
| iPad 13" | 2064 x 2752 px | iPad Pro 13-inch (M4) simulator |

**Note:** 6.7" (per D-07) does NOT have a separate upload slot in App Store Connect — it auto-scales from the 6.9" set. No separate screenshots needed for 6.7". Providing 6.9" covers both 6.9" and 6.7" display sizes.

**Practical minimum:** Upload the 6.9" set + iPad 13" set. The 6.5" set is required only if you do not provide 6.9".

### Required Scenes (minimum 3 per size)

#### Scene 1: Active Gameplay
- **What to show:** 4x4 board with high-value tiles (512, 1024 minimum present)
- **Score:** Non-zero score (target: 4000+ to appear impressive)
- **Power-up bar:** All four power-ups shown in their enabled (non-greyed) state
- **Zone context:** Genesis Zone (purple accent, `#6C63FF`) for brand color consistency
- **Background:** `AppColors.backgroundGradient` visible

#### Scene 2: Level Select / Zone Overview
- **What to show:** All 5 zones visible with their respective accent colors
- **Progress:** At least 2 zones showing partial completion (stars visible on zone cards)
- **Clean state:** No dialogs or overlays — clean zone grid

#### Scene 3: Level Complete Dialog
- **What to show:** Confetti burst active (or captured mid-animation), 3 stars displayed, score and XP shown, Share button visible

### Capture Steps

1. Open Xcode and launch the desired simulator (iPhone 16 Pro Max, iPhone 15 Plus, iPad Pro 13-inch M4)
2. Run the app on the simulator:
   ```bash
   flutter run -d "iPhone 16 Pro Max"
   # or list available devices first:
   flutter devices
   ```
3. Navigate to the appropriate screen and set up the game state:
   - For Scene 1: Play several levels until you have 512+ tiles and all power-ups active
   - For Scene 2: Complete enough levels that 2+ zones show partial progress/stars
   - For Scene 3: Complete a level and capture the dialog at the confetti moment
4. Take screenshot: **Cmd+S** in iOS Simulator (saves to Desktop as PNG)
5. Rename the file descriptively: e.g., `ios-69-gameplay.png`, `ios-65-zones.png`
6. Repeat for each scene and each required device size

### Status Bar

- iOS convention: time shows **9:41** (simulator default when using Cmd+S often shows current time — adjust manually if needed)
- Ensure no carrier text, battery shows full
- Prefer a hidden status bar or a clean dark status bar

### Upload to App Store Connect

1. Go to App Store Connect → Your App → App Store → iPhone Screenshots (6.9")
2. Upload 3–5 screenshots per size
3. Order them: Gameplay → Zone Overview → Level Complete (first impression = gameplay)
4. Repeat for iPad screenshots section

---

## Android — Google Play Console

### Required Sizes

| Device | Minimum | Recommended | Aspect Ratio |
|--------|---------|-------------|-------------|
| Phone | 1080 x 1920 px | 1080 x 1920 px | 9:16 |
| 7" Tablet | 1200 x 1920 px | 1600 x 2560 px | — |
| 10" Tablet | 1600 x 2560 px | 2048 x 2732 px | — |

**Minimum:** 2 screenshots required for phone; 1 for each tablet size if submitted.

### Same 3 Scenes as iOS

Capture on Android emulator (Pixel 8 Pro recommended) or physical Android device.

### Capture Steps

1. Launch Android emulator: use AVD Manager or run `flutter emulators --launch <emulator_id>`
2. Run the app:
   ```bash
   flutter run -d "Pixel 8 Pro"
   # or list available emulators:
   flutter emulators
   ```
3. Navigate to the desired screen and set up game state (same as iOS)
4. Take screenshot: **Cmd+S** (macOS) or the camera icon in Android Emulator toolbar
5. Screenshots save to Desktop or the emulator's screenshot folder

### Status Bar

- Hide status bar or ensure it shows a clean state (no carrier text, battery full, no notifications)
- Avoid showing a specific time unless you can set it to 9:41 for consistency

### Upload to Google Play Console

1. Go to Google Play Console → Your App → Store presence → Main store listing
2. Scroll to "Phone screenshots" — upload 2–8 screenshots
3. Add tablet screenshots in their respective sections if desired
4. Order: Gameplay → Zone Overview → Level Complete

---

## Framing & Submission Rules

- **No device frames** — submit raw screenshots to both stores. App Store Connect and Play Console apply their own device frames in the store UI.
- **No caption overlays or marketing text** on screenshots — plain gameplay screenshots are safest for v1.2.
- **No alpha transparency** — PNG files must be fully opaque.
- **File format:** PNG preferred; JPEG accepted by both stores.
- **File size:** Keep under 8MB per screenshot.

---

## Checklist Before Upload

- [ ] 6.9" iPhone: 3+ screenshots captured at 1260 x 2736 px
- [ ] 6.5" iPhone (if not using 6.9"): screenshots at 1284 x 2778 or 1242 x 2688 px
- [ ] iPad 13": screenshots at 2064 x 2752 px
- [ ] Android phone: 2+ screenshots at 1080 x 1920 px minimum
- [ ] All 3 scenes covered (Gameplay, Zone Overview, Level Complete)
- [ ] Status bar clean (9:41 convention for iOS)
- [ ] No device frames applied
- [ ] Files named clearly before upload

# App Store Differentiation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Differentiate the app from generic 2048 clones to pass Apple App Store review — rebrand to "Merge Quest", upgrade tile visuals, redesign home screen, and add zone-themed board styling.

**Architecture:** Surface-level UI and metadata changes only. No new data layer, BLoC, or navigation changes. All modifications are to existing widgets, theme files, constants, and platform config files.

**Tech Stack:** Flutter, flutter_bloc, google_fonts, flutter_animate

---

### Task 1: Rebrand App Name and Constants

**Files:**
- Modify: `lib/core/constants/app_constants.dart:6`
- Modify: `ios/Runner/Info.plist:9-10` (CFBundleDisplayName)
- Modify: `android/app/src/main/AndroidManifest.xml:3` (android:label)
- Modify: `pubspec.yaml:2` (description)

- [ ] **Step 1: Update AppConstants**

In `lib/core/constants/app_constants.dart`, change line 6:

```dart
// Old:
static const String appName = '2048: Merge Quest';
// New:
static const String appName = 'Merge Quest';
```

- [ ] **Step 2: Update iOS display name**

In `ios/Runner/Info.plist`, change the value of `CFBundleDisplayName` from `2048: Merge Quest` to `Merge Quest`.

- [ ] **Step 3: Update Android label**

In `android/app/src/main/AndroidManifest.xml`, change `android:label="infinite_2048"` to `android:label="Merge Quest"`.

- [ ] **Step 4: Update pubspec.yaml description**

In `pubspec.yaml`, change line 2:

```yaml
# Old:
description: "An infinite 2048 puzzle game with levels, zones, achievements, and premium features."
# New:
description: "Merge Quest — a number merge puzzle with 5 zones, special tiles, and 50 hand-crafted levels."
```

- [ ] **Step 5: Run flutter analyze**

Run: `flutter analyze`
Expected: No new errors

- [ ] **Step 6: Commit**

```bash
git add lib/core/constants/app_constants.dart ios/Runner/Info.plist android/app/src/main/AndroidManifest.xml pubspec.yaml
git commit -m "feat: rebrand app to Merge Quest"
```

---

### Task 2: Redesign Home Screen Header

**Files:**
- Modify: `lib/features/home/presentation/pages/home_page.dart:109-171` (_Header widget)
- Modify: `lib/features/home/presentation/pages/home_page.dart:1-18` (imports)
- Modify: `lib/features/home/presentation/pages/home_page.dart:27-106` (_HomePageState — add zone data loading)

- [ ] **Step 1: Add zone data imports and state**

At the top of `home_page.dart`, add import:

```dart
import '../../../levels/data/datasources/levels_local_datasource.dart';
```

In `_HomePageState`, add a field to track current zone progress:

```dart
String _currentZoneName = 'Genesis';
String _currentZoneId = 'genesis';
int _currentLevel = 1;
int _zoneLevelCount = 10;
int _zoneCompletedLevels = 0;
```

In the `_loadProfile()` method, after loading the profile, also determine the current zone:

```dart
void _loadProfile() {
  final ds = sl<ProgressionLocalDataSource>();
  final levelsDs = sl<LevelsLocalDataSource>();
  setState(() {
    _profile = ds.getProfile();
    _loadCurrentZone(levelsDs);
  });
}

void _loadCurrentZone(LevelsLocalDataSource levelsDs) {
  final zones = levelsDs.getZones();
  for (final zone in zones) {
    final levels = levelsDs.getLevelsForZone(zone.id);
    final completed = levels.where((l) => l.isCompleted).length;
    if (completed < levels.length) {
      _currentZoneName = zone.name;
      _currentZoneId = zone.id;
      _zoneLevelCount = levels.length;
      _zoneCompletedLevels = completed;
      _currentLevel = completed + 1;
      return;
    }
  }
  // All zones completed — default to last zone
  final lastZone = zones.last;
  _currentZoneName = lastZone.name;
  _currentZoneId = lastZone.id;
  _zoneLevelCount = 10;
  _zoneCompletedLevels = 10;
  _currentLevel = 50;
}
```

- [ ] **Step 2: Replace the _Header widget**

Replace the entire `_Header` class (lines 109-171) with a new version that leads with "MERGE QUEST" as hero text and shows zone progress:

```dart
class _Header extends StatelessWidget {
  final String zoneName;
  final String zoneId;
  final int currentLevel;
  final int zoneLevelCount;
  final int zoneCompletedLevels;

  const _Header({
    required this.zoneName,
    required this.zoneId,
    required this.currentLevel,
    required this.zoneLevelCount,
    required this.zoneCompletedLevels,
  });

  Color _zoneColor() {
    switch (zoneId) {
      case 'genesis': return AppColors.zoneGenesis;
      case 'inferno': return AppColors.zoneInferno;
      case 'glacier': return AppColors.zoneGlacier;
      case 'nexus': return AppColors.zoneNexus;
      case 'void': return AppColors.zoneVoid;
      default: return AppColors.zoneEndless;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zoneColor = _zoneColor();
    final progress = zoneLevelCount > 0
        ? zoneCompletedLevels / zoneLevelCount
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MERGE QUEST',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.0,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'The Ultimate Number Puzzle',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      state is AuthAuthenticated
                          ? state.user.username[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.settings_rounded,
                color: AppColors.textSecondary,
              ),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Zone progress indicator
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: zoneColor.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: zoneColor.withAlpha(40), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: zoneColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Zone: $zoneName',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: zoneColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Level $currentLevel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: zoneColor.withAlpha(30),
                  valueColor: AlwaysStoppedAnimation<Color>(zoneColor),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Update _Header usage in build method**

In the `build` method of `_HomePageState` (around line 66), change:

```dart
// Old:
_Header(),
// New:
_Header(
  zoneName: _currentZoneName,
  zoneId: _currentZoneId,
  currentLevel: _currentLevel,
  zoneLevelCount: _zoneLevelCount,
  zoneCompletedLevels: _zoneCompletedLevels,
),
```

- [ ] **Step 4: Update Play button to show zone context**

Replace the `_PlayButton` class (lines 173-204) to show zone-aware CTA:

```dart
class _PlayButton extends StatelessWidget {
  final VoidCallback? onReturn;
  final String zoneName;
  final String zoneId;

  const _PlayButton({this.onReturn, required this.zoneName, required this.zoneId});

  Color _zoneColor() {
    switch (zoneId) {
      case 'genesis': return AppColors.zoneGenesis;
      case 'inferno': return AppColors.zoneInferno;
      case 'glacier': return AppColors.zoneGlacier;
      case 'nexus': return AppColors.zoneNexus;
      case 'void': return AppColors.zoneVoid;
      default: return AppColors.zoneEndless;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zoneColor = _zoneColor();
    return AnimatedButton(
      onPressed: () => context.push('/zones').then((_) => onReturn?.call()),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [zoneColor, zoneColor.withAlpha(180)],
      ),
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 32, color: Colors.white),
            const SizedBox(width: 12),
            Column(
              children: [
                const Text(
                  'CONTINUE QUEST',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  zoneName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Update _PlayButton usage in build method**

```dart
// Old:
_PlayButton(
  onReturn: _refresh,
)
// New:
_PlayButton(
  onReturn: _refresh,
  zoneName: _currentZoneName,
  zoneId: _currentZoneId,
)
```

- [ ] **Step 6: Update Endless mode description**

In `_EndlessModeButton`, change line 250 from:

```dart
'Classic 2048 -- play until you get stuck',
```

to:

```dart
'No limits -- merge as far as you can',
```

- [ ] **Step 7: Run flutter analyze**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 8: Commit**

```bash
git add lib/features/home/presentation/pages/home_page.dart
git commit -m "feat: redesign home screen with quest-focused branding and zone progress"
```

---

### Task 3: Enhance Special Tile Visuals in TileWidget

**Files:**
- Modify: `lib/features/game/presentation/widgets/tile_widget.dart` (entire special tile rendering)

This is the highest-impact change. Each special tile type gets a distinct visual identity.

- [ ] **Step 1: Enhance blocker tile visuals**

In `tile_widget.dart`, replace the `_blockerContent` method (lines 384-392) with a cross-hatch pattern and heavier visual:

```dart
Widget _blockerContent(double tileSize) {
  return Stack(
    children: [
      // Cross-hatch pattern background
      Positioned.fill(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(tileSize * 0.14),
          child: CustomPaint(
            painter: _CrossHatchPainter(
              color: const Color(0xFF333355),
            ),
          ),
        ),
      ),
      Center(
        child: Icon(
          Icons.block_rounded,
          size: tileSize * 0.45,
          color: const Color(0xFF555577),
        ),
      ),
    ],
  );
}
```

Also replace the blocker decoration in `_tileDecoration` (lines 234-239) to look heavier:

```dart
if (widget.tile.specialType == SpecialTileType.blocker) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1E1E38), Color(0xFF12122A)],
    ),
    borderRadius: radius,
    border: Border.all(color: const Color(0xFF444466), width: 2.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(80),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  );
}
```

- [ ] **Step 2: Enhance frozen/ice overlay**

Replace the `_frozenOverlay` method (lines 517-568) with a more distinctive cracked-ice look:

```dart
Widget _frozenOverlay(double tileSize) {
  return Positioned.fill(
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.cyan.withAlpha(90),
            Colors.lightBlueAccent.withAlpha(70),
            Colors.cyan.withAlpha(80),
          ],
        ),
        borderRadius: BorderRadius.circular(tileSize * 0.14),
        border: Border.all(color: Colors.cyan.withAlpha(200), width: 2.5),
      ),
      child: Stack(
        children: [
          // Cracked ice lines
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(tileSize * 0.14),
              child: CustomPaint(
                painter: _IceCrackPainter(
                  color: Colors.white.withAlpha(60),
                ),
              ),
            ),
          ),
          // Snowflake top-left
          Positioned(
            top: tileSize * 0.06,
            left: tileSize * 0.06,
            child: Icon(Icons.ac_unit_rounded,
                size: tileSize * 0.2, color: Colors.white.withAlpha(180)),
          ),
          // Snowflake bottom-right (smaller)
          Positioned(
            bottom: tileSize * 0.06,
            right: tileSize * 0.06,
            child: Icon(Icons.ac_unit_rounded,
                size: tileSize * 0.14, color: Colors.white.withAlpha(120)),
          ),
          // Frozen turns badge
          Positioned(
            top: tileSize * 0.06,
            right: tileSize * 0.06,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF006DB3),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withAlpha(100),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                '${widget.tile.frozenTurns}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: tileSize * 0.12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 3: Enhance wildcard visuals with rainbow border**

Replace the `_wildcardBackground` method (lines 478-494) and wildcard decoration to use a rainbow shimmer:

```dart
Widget _wildcardBackground(double tileSize) {
  return Positioned.fill(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(tileSize * 0.14),
      child: Stack(
        children: [
          // "?" watermark behind the number
          Center(
            child: Text(
              '?',
              style: GoogleFonts.spaceGrotesk(
                fontSize: tileSize * 0.65,
                fontWeight: FontWeight.w900,
                color: Colors.white.withAlpha(25),
              ),
            ),
          ),
          // Prismatic edge glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(tileSize * 0.14),
                border: Border.all(
                  color: Colors.white.withAlpha(50),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

Update the wildcard decoration in `_tileDecoration` (lines 290-312) to add a rainbow-ish gradient:

```dart
if (widget.tile.specialType == SpecialTileType.wildcard) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFB893FF),
        Color(0xFF6C63FF),
        Color(0xFF63B0FF),
        Color(0xFF6C63FF),
        Color(0xFFB893FF),
      ],
      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
    ),
    borderRadius: radius,
    border: Border.all(color: const Color(0xFFD4CFFF).withAlpha(180), width: 2),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withAlpha(120),
        blurRadius: 14,
        spreadRadius: 3,
      ),
      BoxShadow(
        color: const Color(0xFF63B0FF).withAlpha(40),
        blurRadius: 24,
        spreadRadius: 4,
      ),
    ],
  );
}
```

- [ ] **Step 4: Add the new CustomPainter classes**

Add these at the end of the file (after `_RadialPatternPainter`):

```dart
class _CrossHatchPainter extends CustomPainter {
  final Color color;

  _CrossHatchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const spacing = 8.0;
    // Diagonal lines (top-left to bottom-right)
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
    // Diagonal lines (top-right to bottom-left)
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i + size.height, 0), Offset(i, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IceCrackPainter extends CustomPainter {
  final Color color;

  _IceCrackPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Central crack branching outward
    final path = Path()
      ..moveTo(cx * 0.3, cy * 0.2)
      ..lineTo(cx * 0.7, cy * 0.6)
      ..lineTo(cx * 1.0, cy * 0.5)
      ..moveTo(cx * 0.7, cy * 0.6)
      ..lineTo(cx * 0.6, cy * 1.1)
      ..lineTo(cx * 0.9, cy * 1.4)
      ..moveTo(cx * 0.6, cy * 1.1)
      ..lineTo(cx * 0.3, cy * 1.3)
      ..moveTo(cx * 1.2, cy * 0.8)
      ..lineTo(cx * 1.5, cy * 1.2)
      ..lineTo(cx * 1.7, cy * 1.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

- [ ] **Step 5: Enhance regular tile gradient for more depth**

In `_tileDecoration`, update the regular tile decoration (lines 314-344) to add an inner shadow effect via a second gradient layer. Replace the gradient colors:

```dart
// In the default return of _tileDecoration, update the gradient:
final baseColor = theme.colorForValue(widget.tile.value);

return BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.lerp(baseColor, Colors.white, 0.15)!,
      baseColor,
      Color.lerp(baseColor, Colors.black, 0.12)!,
    ],
  ),
  borderRadius: radius,
  border: Border.all(
    color: Color.lerp(baseColor, Colors.white, 0.2)!.withAlpha(40),
    width: 0.5,
  ),
  boxShadow: [
    BoxShadow(
      color: baseColor.withAlpha((40 + elevation * 5).clamp(0, 255).toInt()),
      blurRadius: elevation * 1.5,
      spreadRadius: elevation * 0.3,
      offset: Offset(0, elevation * 0.4),
    ),
    if (widget.tile.value >= 64)
      BoxShadow(
        color: baseColor.withAlpha(30),
        blurRadius: 16,
        spreadRadius: 2,
      ),
  ],
);
```

- [ ] **Step 6: Run flutter analyze**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 7: Commit**

```bash
git add lib/features/game/presentation/widgets/tile_widget.dart
git commit -m "feat: enhance special tile visuals with distinct icons, patterns, and effects"
```

---

### Task 4: Add Zone-Themed Board Styling

**Files:**
- Modify: `lib/features/game/presentation/widgets/game_board.dart`
- Modify: `lib/features/game/presentation/pages/game_page.dart:361-371` (pass zoneId to GameBoard)

- [ ] **Step 1: Add zoneId parameter to GameBoard**

In `game_board.dart`, add a `zoneId` parameter:

```dart
class GameBoard extends StatelessWidget {
  final Board board;
  final bool isHammerMode;
  final ValueChanged<String>? onTileTap;
  final String zoneId;

  const GameBoard({
    super.key,
    required this.board,
    this.isHammerMode = false,
    this.onTileTap,
    this.zoneId = 'genesis',
  });
```

- [ ] **Step 2: Add zone color helper method**

Add a method to GameBoard:

```dart
Color _zoneAccentColor() {
  switch (zoneId) {
    case 'genesis': return AppColors.zoneGenesis;
    case 'inferno': return AppColors.zoneInferno;
    case 'glacier': return AppColors.zoneGlacier;
    case 'nexus': return AppColors.zoneNexus;
    case 'void': return AppColors.zoneVoid;
    default: return AppColors.zoneEndless;
  }
}
```

- [ ] **Step 3: Update board container decoration**

Replace the board container's decoration (lines 33-52) to use zone-themed colors:

```dart
final zoneColor = _zoneAccentColor();

// In the Container decoration:
decoration: BoxDecoration(
  color: AppColors.gridBackground,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(
    color: zoneColor.withAlpha(50),
    width: 1.5,
  ),
  boxShadow: [
    // Zone-colored ambient glow
    BoxShadow(
      color: zoneColor.withAlpha(18),
      blurRadius: 30,
      spreadRadius: 4,
    ),
    // Inner depth shadow
    BoxShadow(
      color: Colors.black.withAlpha(40),
      blurRadius: 12,
      spreadRadius: -2,
      offset: const Offset(0, 4),
    ),
  ],
),
```

- [ ] **Step 4: Update empty cell styling with zone tint**

Update the empty cell decoration (lines 68-78) to add a subtle zone-colored tint:

```dart
decoration: BoxDecoration(
  color: Color.lerp(AppColors.cellEmpty, zoneColor, 0.03),
  borderRadius: BorderRadius.circular(cellSize * 0.12),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withAlpha(20),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
    // Subtle inset shadow for depth
    BoxShadow(
      color: Colors.black.withAlpha(10),
      blurRadius: 1,
      spreadRadius: -1,
    ),
  ],
),
```

- [ ] **Step 5: Pass zoneId from GamePage to GameBoard**

In `game_page.dart`, update the `GameBoard` call in `_buildBoardZone` (around line 361):

```dart
GameBoard(
  board: session.board,
  isHammerMode: _isHammerMode,
  zoneId: widget.level.zoneId,
  onTileTap: _isHammerMode
      ? (tileId) {
          sl<HapticService>().medium();
          context.read<GameBloc>().add(UseHammer(tileId));
          setState(() => _isHammerMode = false);
        }
      : null,
),
```

- [ ] **Step 6: Run flutter analyze**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 7: Commit**

```bash
git add lib/features/game/presentation/widgets/game_board.dart lib/features/game/presentation/pages/game_page.dart
git commit -m "feat: add zone-themed board styling with colored borders and ambient glow"
```

---

### Task 5: Update Store Listing Metadata

**Files:**
- Modify: `STORE_LISTING.md`

- [ ] **Step 1: Update app name and subtitle**

Change the iOS App Name from `2048: Merge Quest` to `Merge Quest` (line 9).
Change the subtitle from `Puzzle Game with 50 Levels` to `Zones, Special Tiles & Daily Fun` (line 15).

- [ ] **Step 2: Update keywords**

Replace the keywords (line 21-22) with:

```
merge quest,zone puzzle,bomb tile,ice tile,daily puzzle,number merge,tile quest,strategy,offline,endless,special tiles,wildcard,multiplier,logic game
```

- [ ] **Step 3: Rewrite promotional text**

Replace the promotional text (lines 36-44) with:

```
5 Zones. 5 Special Tiles. 50 Hand-Crafted Levels. Master bomb explosions in Inferno, navigate frozen tiles in Glacier, and combine all mechanics in The Void. Includes Daily & Weekly Challenges — a fresh puzzle every day. Free to play, works offline.
```

- [ ] **Step 4: Rewrite description opening**

Replace the first paragraph of the description (lines 46-55) to lead with unique mechanics:

```
Welcome to Merge Quest — a number-merge puzzle reimagined with explosive mechanics, zone-based progression, and hand-crafted challenges.

FIVE UNIQUE ZONES, FIVE SPECIAL TILES
Each zone introduces a new tile mechanic that changes how you play:
- Genesis: Master the fundamentals on boards from 3x3 to 4x4
- Inferno: Bomb tiles explode on merge, triggering chain reactions
- Glacier: Ice tiles freeze in place, blocking your path for turns
- Nexus: Multiplier tiles boost your score, Wildcard tiles merge with anything
- The Void: All mechanics combine in the ultimate challenge

50 HAND-CRAFTED LEVELS
Every level is intentionally designed with specific goals, board sizes, and difficulty. This isn't random — it's a carefully crafted puzzle journey.
```

- [ ] **Step 5: Update Google Play listing similarly**

Update the Play Store app name (line 131) to `Merge Quest`.
Update the short description (lines 135-145) to:

```
5 zones, 5 special tiles, 50 hand-crafted levels. Master bomb explosions, ice mechanics, and more!
```

Update the full description opening to match the iOS rewrite above.

- [ ] **Step 6: Update ASO keyword strategy**

Update the primary keywords section (around line 213) to:

```
- Primary: merge quest, merge puzzle, tile quest, zone puzzle, special tiles
- Secondary: bomb tile game, ice puzzle, daily puzzle, number merge, offline puzzle
- Long-Tail: merge quest zones, puzzle with special tiles, daily number challenge, merge bomb puzzle
```

- [ ] **Step 7: Commit**

```bash
git add STORE_LISTING.md
git commit -m "feat: rewrite store listing to emphasize unique mechanics and zones"
```

---

### Task 6: Update Endless Mode Board (zoneId handling)

**Files:**
- Modify: `lib/features/endless/presentation/pages/endless_page.dart` (pass zoneId to GameBoard)

- [ ] **Step 1: Find and update GameBoard usage in endless mode**

The endless mode also uses `GameBoard`. Find the GameBoard instantiation and add `zoneId: 'endless'`:

```dart
GameBoard(
  board: session.board,
  isHammerMode: _isHammerMode,
  zoneId: 'endless',
  onTileTap: // ... existing code
),
```

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/endless/presentation/pages/endless_page.dart
git commit -m "feat: add endless zone styling to endless mode board"
```

---

### Task 7: Final Verification

**Files:** None (verification only)

- [ ] **Step 1: Run flutter analyze**

Run: `flutter analyze`
Expected: No errors or warnings related to our changes

- [ ] **Step 2: Run flutter build ios --no-codesign**

Run: `flutter build ios --no-codesign`
Expected: Build completes successfully

- [ ] **Step 3: Verify all branding references are updated**

Search for any remaining "2048" references in app-facing text:

```bash
grep -r "2048" lib/ --include="*.dart" -l
```

Review results — some will be legitimate (tile values, game constants). Flag any that are user-facing branding text and update them.

- [ ] **Step 4: Commit any final fixes**

```bash
git add -A
git commit -m "chore: final verification and cleanup for App Store resubmission"
```

# Future Improvements - Infinite 2048

Implementation instructions for planned app enhancements. The app is a Flutter 2048-style puzzle game using clean architecture with flutter_bloc, get_it, go_router, hive_flutter, and Firebase.

---

## Table of Contents

1. [Endless Mode](#1-endless-mode)
2. [Hint System (Premium)](#2-hint-system-premium)
3. [Level Replay Value / Secondary Objectives](#3-level-replay-value--secondary-objectives)
4. [Confetti / Enhanced Celebrations](#4-confetti--enhanced-celebrations)
5. [Custom Page Transitions](#5-custom-page-transitions)
6. [Board Themes](#6-board-themes)
7. [Color Blind Mode](#7-color-blind-mode)
8. [Share Score](#8-share-score)
9. [Splash Screen](#9-splash-screen)
10. [Push Notifications](#10-push-notifications)
11. [Firebase Analytics Events](#11-firebase-analytics-events)
12. [Crashlytics](#12-crashlytics)
13. [Tablet / Responsive Layout](#13-tablet--responsive-layout)
14. [Seasonal Events](#14-seasonal-events)
15. [Custom Level Creator](#15-custom-level-creator)
16. [Recommended Implementation Order](#recommended-implementation-order)

---

## 1. Endless Mode

**Priority:** P1 | **Effort:** Large

### What It Is and Why It Matters

After completing all 50 story levels (5 zones x 10 levels), players unlock an endless mode with a single ever-growing board. The goal is to survive as long as possible. An online leaderboard via Cloud Firestore drives competition and retention.

### Files to Create

- `lib/features/endless/domain/entities/endless_session.dart` - Endless game state (board, score, board expansion rules)
- `lib/features/endless/domain/repositories/endless_repository.dart` - Abstract repository for endless mode
- `lib/features/endless/data/repositories/endless_repository_impl.dart` - Local + Firestore implementation
- `lib/features/endless/data/datasources/endless_local_datasource.dart` - Hive persistence for current run
- `lib/features/endless/data/datasources/endless_leaderboard_datasource.dart` - Firestore read/write for leaderboard
- `lib/features/endless/presentation/bloc/endless_bloc.dart` - Endless game logic
- `lib/features/endless/presentation/pages/endless_game_page.dart` - Game UI (reuse GameBoard, adapt for dynamic size)
- `lib/features/endless/presentation/pages/endless_leaderboard_page.dart` - Top scores display

### Files to Modify

- `lib/app/router.dart` - Add `/endless` and `/endless/leaderboard` routes
- `lib/app/di.dart` - Register endless datasources, repository, bloc
- `lib/features/home/presentation/pages/home_page.dart` - Add Endless Mode card (visible when `getTotalStars() >= 150` or all zones complete)
- `lib/features/levels/data/datasources/levels_local_datasource.dart` - Add `bool isAllStoryLevelsComplete()` helper
- `lib/features/game/domain/engine/game_engine.dart` - Add `expandBoard(Board board)` for adding rows/columns when reaching edge tiles

### Implementation Notes

**Board expansion logic:** When the highest tile reaches a threshold (e.g., 4096), expand the board by 1 row and 1 column. Start at 4x4, grow to 5x5, 6x6, etc.

```dart
// Pseudocode for expansion
static Board expandBoard(Board board) {
  final newSize = board.size + 1;
  var tiles = board.tiles.map((t) => t).toList();
  // Shift tiles if needed, add empty cells
  return Board(size: newSize, tiles: tiles, score: board.score, moveCount: board.moveCount);
}
```

**Firestore structure:**
```
leaderboard_endless/
  {userId}/
    score: number
    highestTile: number
    boardSizeReached: number
    timestamp: Timestamp
    displayName: string
```

Use Firestore `orderBy('score', descending: true).limit(100)` for queries. Secure with rules: read public, write only own document.

### Dependencies

- `cloud_firestore` (already present)

---

## 2. Hint System (Premium)

**Priority:** P2 | **Effort:** Large

### What It Is and Why It Matters

A "Show Best Move" button highlights the optimal swipe direction using minimax or expectimax algorithm. 1 free hint per level for all users; unlimited for premium subscribers. Increases conversion and helps stuck players.

### Files to Create

- `lib/features/game/domain/engine/hint_engine.dart` - Expectimax/minimax implementation
- `lib/features/game/presentation/widgets/hint_overlay.dart` - Arrow or glow indicating best direction

### Files to Modify

- `lib/features/game/presentation/bloc/game_bloc.dart` - Add `RequestHint` event, `hintsUsedThisLevel`, `hintsRemaining` to state
- `lib/features/game/presentation/bloc/game_event.dart` - Add `RequestHint`
- `lib/features/game/presentation/bloc/game_state.dart` - Add `bestMoveDirection`, `hintsRemaining`
- `lib/features/game/presentation/pages/game_page.dart` - Add hint button, show HintOverlay when hint active
- `lib/features/game/presentation/widgets/powerup_bar.dart` - Add hint button with count badge

### Implementation Notes

**Expectimax (simplified):** Evaluate each of the 4 directions by simulating random tile spawns and computing expected score. Depth 2-3 is usually sufficient for responsiveness.

```dart
// Pseudocode
MoveDirection getBestMove(Board board) {
  double bestScore = double.negativeInfinity;
  MoveDirection best = MoveDirection.up;
  for (final dir in MoveDirection.values) {
    final result = GameEngine.moveTiles(board, dir);
    if (!result.boardChanged) continue;
    final eval = _expectimax(result.board, depth: 2);
    if (eval > bestScore) { bestScore = eval; best = dir; }
  }
  return best;
}
```

Run `getBestMove` in an isolate to avoid UI jank. Use `compute()` or `Isolate.run()`.

**Premium check:** Inject `SubscriptionRepository` into GameBloc; if `isPremium` then `hintsRemaining = -1` (unlimited), else `hintsRemaining = 1 - hintsUsedThisLevel`.

### Dependencies

- None (use existing packages)

---

## 3. Level Replay Value / Secondary Objectives

**Priority:** P3 | **Effort:** Medium

### What It Is and Why It Matters

After earning 3 stars, add bonus objectives like "Complete in under 20 moves" or "Reach 4096 instead of 2048" for bonus XP. Increases replay value without blocking progression.

### Files to Create

- `lib/features/levels/domain/entities/secondary_objective.dart` - Type enum (moveLimit, targetOverride), target value, bonus XP
- `lib/features/game/presentation/widgets/secondary_objective_banner.dart` - Shows available bonus objectives

### Files to Modify

- `lib/features/levels/domain/entities/level.dart` - Add `List<SecondaryObjective>? secondaryObjectives`
- `lib/features/levels/data/datasources/levels_local_datasource.dart` - Define secondary objectives per level (e.g., void_10: "Reach 131072 in under 120 moves" = +50 XP)
- `lib/features/game/presentation/bloc/game_bloc.dart` - On level complete, check secondary objectives and award bonus XP
- `lib/features/game/presentation/widgets/level_complete_dialog.dart` - Show bonus objectives completed and XP gained

### Implementation Notes

```dart
class SecondaryObjective {
  final String id;
  final SecondaryObjectiveType type; // moveLimit, targetOverride
  final int targetValue;
  final int bonusXp;
}
```

Store completion in Hive: `secondary_objectives/{levelId}_{objectiveId}` = true.

### Dependencies

- None

---

## 4. Confetti / Enhanced Celebrations

**Priority:** P3 | **Effort:** Small

### What It Is and Why It Matters

Beyond current star display: animated star-filling (draw/scribble effect), score counter tick-up animation, more particle variety (stars, sparkles, ribbons). Improves satisfaction on level completion.

### Files to Create

- `lib/features/game/presentation/widgets/confetti_overlay.dart` - Confetti canvas using `CustomPainter` or `confetti` package
- `lib/features/game/presentation/widgets/animated_score_counter.dart` - TweenAnimationBuilder from old to new score

### Files to Modify

- `lib/features/game/presentation/widgets/level_complete_dialog.dart` - Replace static stars with animated star-fill, use AnimatedScoreCounter for score, wrap in ConfettiOverlay
- `lib/features/game/presentation/widgets/particle_effects.dart` - Add `ParticleType` enum (circle, star, ribbon), vary shapes in `_ParticlePainter`

### Implementation Notes

**Animated score counter:**
```dart
TweenAnimationBuilder<int>(
  tween: IntTween(begin: 0, end: score),
  duration: Duration(milliseconds: 1200),
  builder: (context, value, _) => Text('$value'),
)
```

**Star fill:** Use `flutter_animate` with custom effect or `CustomPainter` drawing star outline that fills over ~400ms.

### Dependencies

- Optional: `confetti` or `lottie` for richer effects

---

## 5. Custom Page Transitions

**Priority:** P1 | **Effort:** Small

### What It Is and Why It Matters

Use `CustomTransitionPage` in GoRouter for slide/fade transitions between routes instead of default Material transitions. Adds polish and brand consistency.

### Files to Modify

- `lib/app/router.dart` - Replace `builder` with `pageBuilder` returning `CustomTransitionPage` for each route

### Implementation Notes

```dart
GoRoute(
  path: '/zones',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: BlocProvider(
      create: (_) => sl<LevelsBloc>()..add(const LoadZones()),
      child: const ZoneSelectionPage(),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  ),
),
```

Create a shared `_slideTransition` helper to reuse across routes. Use `Offset(0, 0.1)` for subtle upward slide on modal-like pages.

### Dependencies

- None

---

## 6. Board Themes

**Priority:** P2 | **Effort:** Medium

### What It Is and Why It Matters

Board surface options (wood grain, marble, dark glass) as additional unlockables. Different from tile color themes in `TileThemes`; these affect the grid background and cell appearance.

### Files to Create

- `lib/features/progression/domain/entities/board_theme.dart` - id, name, decoration (gradient/image path), unlockCondition
- `lib/core/theme/board_themes.dart` - Static definitions similar to `TileThemes`

### Files to Modify

- `lib/features/progression/domain/entities/player_profile.dart` - Add `activeBoardThemeId`, `unlockedBoardThemeIds`
- `lib/features/progression/data/datasources/progression_local_datasource.dart` - Persist board theme in profile
- `lib/features/game/presentation/widgets/game_board.dart` - Use `BoardThemes.decorationFor(activeBoardThemeId)` for grid Container
- `lib/features/progression/presentation/pages/theme_selection_page.dart` - Add tab or section for board themes

### Implementation Notes

**Board theme decoration examples:**
- Wood: `BoxDecoration` with `DecorationImage` using asset `assets/board/wood_grain.png`, repeat
- Marble: Linear gradient with subtle noise
- Dark glass: `BoxDecoration` with `color: Colors.black26`, `border: Border.all(color: Colors.white12)`

### Dependencies

- None (use `DecorationImage` with assets)

---

## 7. Color Blind Mode

**Priority:** P2 | **Effort:** Small

### What It Is and Why It Matters

Add number shapes or patterns on tiles for accessibility. Users with color vision deficiency can distinguish tiles by shape in addition to color.

### Files to Create

- `lib/core/theme/tile_patterns.dart` - Map value to pattern (e.g., 2 = diagonal lines, 4 = grid, 8 = dots)

### Files to Modify

- `lib/features/game/presentation/widgets/tile_widget.dart` - When `colorBlindMode` is true, overlay `CustomPaint` with pattern from `TilePatterns.patternFor(value)`
- `lib/features/settings/presentation/pages/settings_page.dart` - Add "Color Blind Mode" switch under ACCESSIBILITY section
- `lib/core/constants/app_constants.dart` - Add `hiveColorBlindMode` key; store in Hive settings box

### Implementation Notes

```dart
// In TileWidget._valueContent, when colorBlindMode:
Stack(
  children: [
    Text(tile.value.toString(), ...),
    CustomPaint(
      painter: TilePatternPainter(
        pattern: TilePatterns.patternFor(tile.value),
        color: textColor.withAlpha(100),
      ),
      size: Size(tileSize, tileSize),
    ),
  ],
)
```

Patterns: 2 = single diagonal, 4 = cross, 8 = 2x2 dots, 16 = 4 corners, etc. Keep patterns simple and distinct.

### Dependencies

- None

---

## 8. Share Score

**Priority:** P1 | **Effort:** Small

### What It Is and Why It Matters

Generate styled text or image share after level completion (similar to Wordle). Drives organic growth through social sharing.

### Files to Create

- `lib/features/game/domain/services/share_service.dart` - Build share text/image, invoke share_plus

### Files to Modify

- `lib/features/game/presentation/widgets/level_complete_dialog.dart` - Add "Share" button; on tap call `ShareService.shareLevelResult(levelNumber, score, stars)`
- `lib/app/di.dart` - Register ShareService

### Implementation Notes

```dart
// Share text format (Wordle-style)
final text = '''
Infinite 2048 - Level $levelNumber Complete!
Score: $score | Stars: $stars

Play at [app store link]
''';
await Share.share(text);
```

For image: use `RepaintBoundary` + `RenderRepaintBoundary.toImage()` to capture level complete dialog, then `Share.shareXFiles([XFile.fromData(pngBytes)])`.

### Dependencies

- `share_plus: ^10.0.0`

---

## 9. Splash Screen

**Priority:** P0 | **Effort:** Small

### What It Is and Why It Matters

Use flutter_native_splash for a branded loading screen while the app initializes. Improves perceived performance and brand consistency.

### Files to Create

- `flutter_native_splash.yaml` - Configuration for splash assets and background

### Files to Modify

- `pubspec.yaml` - Add `flutter_native_splash` dev dependency and assets
- `lib/main.dart` - Call `await FlutterNativeSplash.preserve()` before runApp; `FlutterNativeSplash.remove()` after first frame or when ready

### Implementation Notes

```yaml
# flutter_native_splash.yaml
flutter_native_splash:
  color: "#0A0E21"
  image: assets/splash/logo.png
  android_12:
    color: "#0A0E21"
    image: assets/splash/logo.png
```

```dart
// main.dart
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // ... init Hive, Firebase, etc.
  runApp(const InfiniteApp());
  FlutterNativeSplash.remove();
}
```

### Dependencies

- `flutter_native_splash: ^2.4.0` (dev_dependencies)

---

## 10. Push Notifications

**Priority:** P2 | **Effort:** Medium

### What It Is and Why It Matters

"Your daily challenge is ready!" and similar engagement messages using firebase_messaging. Increases daily active users.

### Files to Create

- `lib/core/services/notification_service.dart` - Initialize FCM, request permission, handle foreground/background messages
- `lib/core/services/notification_scheduler.dart` - Schedule local notifications (optional, for "daily challenge" at fixed time)

### Files to Modify

- `lib/main.dart` - Initialize NotificationService, set up FCM background handler
- `lib/app/di.dart` - Register NotificationService
- `android/app/src/main/AndroidManifest.xml` - Add FCM metadata and intent filters
- `ios/Runner/AppDelegate.swift` - Configure FCM

### Implementation Notes

```dart
class NotificationService {
  Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }
  void _handleNotificationTap(RemoteMessage message) {
    if (message.data['type'] == 'daily_challenge') {
      // Navigate to /challenge/daily via go_router
    }
  }
}
```

Use Firebase Cloud Messaging console or Cloud Functions to send "Daily challenge ready" at a configured time. Store FCM token in Firestore for targeted sends.

### Dependencies

- `firebase_messaging: ^15.0.0`

---

## 11. Firebase Analytics Events

**Priority:** P0 | **Effort:** Small

### What It Is and Why It Matters

Track key events for product decisions: level_started, level_completed, level_failed, theme_changed, ad_watched, purchase_started. Essential for understanding user behavior.

### Files to Create

- `lib/core/analytics/analytics_service.dart` - Wrapper around FirebaseAnalytics with typed event methods

### Files to Modify

- `lib/app/di.dart` - Register AnalyticsService (only when Firebase available)
- `lib/features/game/presentation/bloc/game_bloc.dart` - Log level_started on StartGame, level_completed/level_failed on win/loss
- `lib/features/progression/presentation/pages/theme_selection_page.dart` - Log theme_changed on selection
- `lib/core/services/ad_service.dart` - Log ad_watched on rewarded ad completion
- `lib/features/subscription/data/repositories/subscription_repository_impl.dart` - Log purchase_started before purchase

### Implementation Notes

```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logLevelStarted(String levelId, String zoneId) async {
    await _analytics.logEvent(
      name: 'level_started',
      parameters: {'level_id': levelId, 'zone_id': zoneId},
    );
  }
  Future<void> logLevelCompleted(String levelId, int score, int stars) async {
    await _analytics.logEvent(
      name: 'level_completed',
      parameters: {'level_id': levelId, 'score': score, 'stars': stars},
    );
  }
  // level_failed, theme_changed, ad_watched, purchase_started
}
```

### Dependencies

- `firebase_analytics: ^11.0.0` (likely already via firebase_core)

---

## 12. Crashlytics

**Priority:** P0 | **Effort:** Small

### What It Is and Why It Matters

Add firebase_crashlytics for production error tracking. Critical for identifying and fixing crashes.

### Files to Modify

- `lib/main.dart` - Wrap runApp in `FlutterError.onError` and `PlatformDispatcher.instance.onError` to forward to Crashlytics; call `FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true)`
- `lib/app/app.dart` - Add `ErrorWidget.builder` to catch build errors

### Implementation Notes

```dart
void main() async {
  // ... after Firebase init
  if (firebaseAvailable) {
    FlutterError.onError = (error) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(error);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  runApp(const InfiniteApp());
}
```

Add `await FirebaseCrashlytics.instance.setUserIdentifier(userId)` when user logs in.

### Dependencies

- `firebase_crashlytics: ^4.0.0`

---

## 13. Tablet / Responsive Layout

**Priority:** P2 | **Effort:** Medium

### What It Is and Why It Matters

Use LayoutBuilder to cap board size and add side panels on larger screens. Improves experience on tablets and foldables.

### Files to Modify

- `lib/features/game/presentation/pages/game_page.dart` - Wrap content in LayoutBuilder; on width > 600, use Row with GameBoard (max 400px) and side panel (stats, powerups, ads)
- `lib/features/game/presentation/widgets/game_board.dart` - Add `maxBoardSize` parameter; cap cellSize so board does not exceed max
- `lib/features/home/presentation/pages/home_page.dart` - On tablet, use 2-column grid for action cards

### Implementation Notes

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final isWide = constraints.maxWidth > 600;
    if (isWide) {
      return Row(
        children: [
          Expanded(child: GameBoard(board: board, maxSize: 400)),
          SizedBox(
            width: 200,
            child: Column(
              children: [ScoreDisplay(...), PowerupBar(...)],
            ),
          ),
        ],
      );
    }
    return Column(children: [...]);
  },
)
```

### Dependencies

- None

---

## 14. Seasonal Events

**Priority:** P3 | **Effort:** Large

### What It Is and Why It Matters

Holiday-themed zones (e.g., Halloween, Winter) with limited-time mechanics and cosmetics. Drives re-engagement and creates urgency.

### Files to Create

- `lib/features/events/domain/entities/seasonal_event.dart` - id, name, startDate, endDate, zoneId, mechanics, cosmetics
- `lib/features/events/data/datasources/events_remote_datasource.dart` - Fetch event config from Firestore or remote config
- `lib/features/events/presentation/pages/seasonal_zone_page.dart` - Themed level selection

### Files to Modify

- `lib/app/router.dart` - Add `/events/:eventId` route
- `lib/features/home/presentation/pages/home_page.dart` - Show seasonal event banner when active
- `lib/core/theme/tile_themes.dart` - Add seasonal tile themes (e.g., pumpkin, snowflake) as unlockables during event

### Implementation Notes

Use Firebase Remote Config to enable/disable events and define dates without app update. Store event progress in Hive. Mechanics could include: "Ghost tiles" that disappear after 3 moves, "Snow tiles" that slow spawn rate, etc.

### Dependencies

- `firebase_remote_config` (optional, for server-driven event config)

---

## 15. Custom Level Creator

**Priority:** P3 | **Effort:** Large

### What It Is and Why It Matters

Let users create and share levels. Community content extends longevity and engagement.

### Files to Create

- `lib/features/creator/domain/entities/custom_level.dart` - Extends Level with authorId, shareCode, createdAt
- `lib/features/creator/presentation/pages/level_editor_page.dart` - Grid editor for board size, blockers, target, spawn rates
- `lib/features/creator/presentation/pages/level_browser_page.dart` - Browse shared levels from Firestore
- `lib/features/creator/data/datasources/custom_levels_datasource.dart` - Firestore CRUD for custom levels

### Files to Modify

- `lib/app/router.dart` - Add `/creator`, `/creator/edit`, `/levels/browse`
- `lib/features/game/domain/entities/level.dart` - Ensure Level can be constructed from JSON for custom levels
- `lib/features/home/presentation/pages/home_page.dart` - Add "Create Level" and "Browse Levels" entries

### Implementation Notes

**Share code:** Encode level config (board size, blockers, target, etc.) into a short string (base64 or custom encoding). Store in Firestore with share code as document ID for easy lookup.

**Firestore structure:**
```
custom_levels/
  {shareCode}/
    authorId, authorName, boardConfig (JSON), createdAt, playCount, likeCount
```

**Editor UI:** Drag-and-drop blockers, number inputs for target and limits, preview mode. Validate level is solvable before allowing share (optional, complex).

### Dependencies

- `cloud_firestore` (already present)

---

## Recommended Implementation Order

Implement in this order for maximum impact with minimal risk:

| Phase | Improvements | Rationale |
|-------|---------------|----------|
| **Phase 1: Foundation** | Splash Screen (9), Firebase Analytics (11), Crashlytics (12) | Quick wins; analytics and stability are prerequisites for growth. Splash improves first impression. |
| **Phase 2: Polish** | Custom Page Transitions (5), Share Score (8), Confetti (4) | Low effort, high perceived quality. Share drives organic growth. |
| **Phase 3: Accessibility & Reach** | Color Blind Mode (7), Tablet Layout (13) | Accessibility and device coverage. |
| **Phase 4: Engagement** | Push Notifications (10), Board Themes (6) | Re-engagement and personalization. |
| **Phase 5: Monetization & Retention** | Hint System (2), Level Replay / Secondary Objectives (3) | Premium value and replay. |
| **Phase 6: Long-term Content** | Endless Mode (1), Seasonal Events (14), Custom Level Creator (15) | Large features that extend lifetime value. |

### Priority Summary

| Priority | Improvements |
|----------|---------------|
| P0 | Splash Screen, Firebase Analytics, Crashlytics |
| P1 | Endless Mode, Share Score, Custom Page Transitions |
| P2 | Hint System, Board Themes, Color Blind Mode, Push Notifications, Tablet Layout |
| P3 | Confetti, Secondary Objectives, Seasonal Events, Custom Level Creator |

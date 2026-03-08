import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'app/di.dart';
import 'core/constants/app_constants.dart';
import 'core/services/ad_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/games_service.dart';
import 'core/services/remote_config_service.dart';
import 'features/progression/data/datasources/progression_local_datasource.dart';
import 'firebase_options.dart';

void main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF0A0E21),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Initialize Hive
      await Hive.initFlutter();
      await Hive.openBox(AppConstants.hiveGameStateBox);
      await Hive.openBox(AppConstants.hiveLevelProgressBox);
      await Hive.openBox(AppConstants.hiveAchievementsBox);
      await Hive.openBox(AppConstants.hiveSettingsBox);
      await Hive.openBox(AppConstants.hiveUserBox);

      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        debugPrint('Firebase not configured: $e');
        debugPrint('Running in offline mode.');
      }

      // Initialize Crashlytics
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      // Disable Crashlytics in debug mode
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      );

      // Initialize dependencies
      await initDependencies();

      // Initialize ad service
      try {
        await sl<AdService>().initialize();
      } catch (_) {
        debugPrint('Ad service initialization failed.');
      }

      // Initialize Firebase services (only if Firebase is available)
      try {
        await sl<AnalyticsService>().initialize();
        sl<AnalyticsService>().logAppOpened();
      } catch (_) {
        debugPrint('Analytics initialization failed.');
      }

      try {
        await sl<RemoteConfigService>().initialize();
      } catch (_) {
        debugPrint('Remote Config initialization failed.');
      }

      // Record login for streak tracking
      try {
        final progressionDs = sl<ProgressionLocalDataSource>();
        await progressionDs.recordLogin();
      } catch (_) {}

      // Check Game Center / Google Play Games sign-in status
      try {
        await sl<GamesService>().checkSignInStatus();
      } catch (_) {
        debugPrint('Games Services check failed.');
      }

      runApp(const InfiniteApp());
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

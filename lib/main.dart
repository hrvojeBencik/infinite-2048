import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'app/di.dart';
import 'core/constants/app_constants.dart';
import 'core/services/ad_service.dart';
import 'features/progression/data/datasources/progression_local_datasource.dart';
import 'firebase_options.dart';

void main() async {
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

  // Initialize Firebase (gracefully handle if not configured)
  bool firebaseAvailable = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseAvailable = true;
  } catch (e) {
    debugPrint('Firebase not configured: $e');
    debugPrint('Running in offline mode.');
  }

  // Initialize dependencies
  await initDependencies(firebaseAvailable: firebaseAvailable);

  // Initialize ad service
  try {
    await sl<AdService>().initialize();
  } catch (_) {
    debugPrint('Ad service initialization failed.');
  }

  // Record login for streak tracking
  try {
    final progressionDs = sl<ProgressionLocalDataSource>();
    await progressionDs.recordLogin();
  } catch (_) {}

  runApp(const InfiniteApp());
}

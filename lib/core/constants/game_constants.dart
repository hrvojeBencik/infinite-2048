class GameConstants {
  GameConstants._();

  static const int minBoardSize = 3;
  static const int maxBoardSize = 8;
  static const int defaultBoardSize = 4;

  static const int baseSpawnValue = 2;
  static const double highValueSpawnChance = 0.1;
  static const int highSpawnValue = 4;

  static const int freeUndosPerLevel = 3;
  static const int premiumHammersPerLevel = 5;
  static const int premiumShufflesPerLevel = 3;
  static const int premiumMergeBoostsPerLevel = 1;

  static const Duration tileAnimationDuration = Duration(milliseconds: 150);
  static const Duration mergeAnimationDuration = Duration(milliseconds: 200);
  static const Duration spawnAnimationDuration = Duration(milliseconds: 150);
  static const Duration explosionAnimationDuration = Duration(milliseconds: 300);

  static const int adsIntervalLevels = 3;

  static const int maxIceFreezeTurns = 3;
}

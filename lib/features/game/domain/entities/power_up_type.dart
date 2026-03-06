enum PowerUpType {
  undo,
  hammer,
  shuffle,
  mergeBoost;

  String get displayName {
    switch (this) {
      case PowerUpType.undo:
        return 'Undo';
      case PowerUpType.hammer:
        return 'Hammer';
      case PowerUpType.shuffle:
        return 'Shuffle';
      case PowerUpType.mergeBoost:
        return 'Merge Boost';
    }
  }

  String get icon {
    switch (this) {
      case PowerUpType.undo:
        return '↩️';
      case PowerUpType.hammer:
        return '🔨';
      case PowerUpType.shuffle:
        return '🔀';
      case PowerUpType.mergeBoost:
        return '⚡';
    }
  }

  bool get isPremiumOnly {
    switch (this) {
      case PowerUpType.undo:
        return false;
      case PowerUpType.hammer:
        return false;
      case PowerUpType.shuffle:
        return true;
      case PowerUpType.mergeBoost:
        return true;
    }
  }
}

enum SpecialTileType {
  none,
  bomb,
  ice,
  multiplier,
  wildcard,
  blocker;

  bool get isMovable => this != blocker && this != ice;
  bool get isMergeable => this != blocker;
}

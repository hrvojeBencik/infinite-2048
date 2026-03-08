import 'package:flutter/material.dart';

class TileTheme {
  final String id;
  final String name;
  final String description;
  final int requiredLevel;
  final bool isPremium;
  final Map<int, Color> tileColors;
  final Color textColorLight;
  final Color textColorDark;

  const TileTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredLevel,
    this.isPremium = false,
    required this.tileColors,
    required this.textColorLight,
    required this.textColorDark,
  });

  Color colorForValue(int value) {
    return tileColors[value] ?? tileColors.values.last;
  }

  Color textColorForValue(int value) {
    return value <= 4 ? textColorLight : textColorDark;
  }
}

class TileThemes {
  TileThemes._();

  static const TileTheme classic = TileTheme(
    id: 'classic',
    name: 'Classic',
    description: 'Original 2048 warm tones',
    requiredLevel: 0,
    tileColors: {
      2: Color(0xFFE8E0D6),
      4: Color(0xFFE8DCC4),
      8: Color(0xFFF2B179),
      16: Color(0xFFF59563),
      32: Color(0xFFF67C5F),
      64: Color(0xFFF65E3B),
      128: Color(0xFFEDCF72),
      256: Color(0xFFEDCC61),
      512: Color(0xFFEDC850),
      1024: Color(0xFFEDC53F),
      2048: Color(0xFFEDC22E),
      4096: Color(0xFF6C63FF),
      8192: Color(0xFF5A4FCF),
    },
    textColorLight: Color(0xFF776E65),
    textColorDark: Color(0xFFFFFFFF),
  );

  static const TileTheme neon = TileTheme(
    id: 'neon',
    name: 'Neon',
    description: 'Vibrant neon colors',
    requiredLevel: 3,
    tileColors: {
      2: Color(0xFF39FF14),
      4: Color(0xFF00FFFF),
      8: Color(0xFFFF1493),
      16: Color(0xFFFF6600),
      32: Color(0xFFFFFF00),
      64: Color(0xFFFF0000),
      128: Color(0xFF00FF7F),
      256: Color(0xFFFF69B4),
      512: Color(0xFF7B68EE),
      1024: Color(0xFFFFD700),
      2048: Color(0xFFFF4500),
    },
    textColorLight: Color(0xFF000000),
    textColorDark: Color(0xFFFFFFFF),
  );

  static const TileTheme ocean = TileTheme(
    id: 'ocean',
    name: 'Ocean',
    description: 'Blue and teal palette',
    requiredLevel: 5,
    tileColors: {
      2: Color(0xFFE0F7FA),
      4: Color(0xFFB2EBF2),
      8: Color(0xFF4DD0E1),
      16: Color(0xFF00BCD4),
      32: Color(0xFF0097A7),
      64: Color(0xFF00838F),
      128: Color(0xFF006064),
      256: Color(0xFF0277BD),
      512: Color(0xFF01579B),
      1024: Color(0xFF1A237E),
      2048: Color(0xFF0D47A1),
    },
    textColorLight: Color(0xFF01579B),
    textColorDark: Color(0xFFFFFFFF),
  );

  static const TileTheme sunset = TileTheme(
    id: 'sunset',
    name: 'Sunset',
    description: 'Warm sunset gradient',
    requiredLevel: 8,
    tileColors: {
      2: Color(0xFFFFF3E0),
      4: Color(0xFFFFE0B2),
      8: Color(0xFFFFCC80),
      16: Color(0xFFFFB74D),
      32: Color(0xFFFFA726),
      64: Color(0xFFFF9800),
      128: Color(0xFFFB8C00),
      256: Color(0xFFF57C00),
      512: Color(0xFFEF6C00),
      1024: Color(0xFFE65100),
      2048: Color(0xFFBF360C),
    },
    textColorLight: Color(0xFFE65100),
    textColorDark: Color(0xFFFFFFFF),
  );

  static const TileTheme galaxy = TileTheme(
    id: 'galaxy',
    name: 'Galaxy',
    description: 'Deep space purples',
    requiredLevel: 12,
    tileColors: {
      2: Color(0xFFE8EAF6),
      4: Color(0xFFC5CAE9),
      8: Color(0xFF9FA8DA),
      16: Color(0xFF7986CB),
      32: Color(0xFF5C6BC0),
      64: Color(0xFF3F51B5),
      128: Color(0xFF3949AB),
      256: Color(0xFF303F9F),
      512: Color(0xFF283593),
      1024: Color(0xFF1A237E),
      2048: Color(0xFF0D47A1),
    },
    textColorLight: Color(0xFF1A237E),
    textColorDark: Color(0xFFFFFFFF),
  );

  static const TileTheme monochrome = TileTheme(
    id: 'mono',
    name: 'Monochrome',
    description: 'Elegant grayscale',
    requiredLevel: 15,
    tileColors: {
      2: Color(0xFFF5F5F5),
      4: Color(0xFFE0E0E0),
      8: Color(0xFFBDBDBD),
      16: Color(0xFF9E9E9E),
      32: Color(0xFF757575),
      64: Color(0xFF616161),
      128: Color(0xFF424242),
      256: Color(0xFF303030),
      512: Color(0xFF212121),
      1024: Color(0xFF1A1A1A),
      2048: Color(0xFF000000),
    },
    textColorLight: Color(0xFF424242),
    textColorDark: Color(0xFFFFFFFF),
  );

  // Premium-exclusive themes
  static const TileTheme diamond = TileTheme(
    id: 'diamond',
    name: 'Diamond',
    description: 'Brilliant icy blues and silvers',
    requiredLevel: 0,
    isPremium: true,
    tileColors: {
      2: Color(0xFFE8F4FD),
      4: Color(0xFFCDE9F7),
      8: Color(0xFFA8D8EA),
      16: Color(0xFF7EC8E3),
      32: Color(0xFF5BB3D5),
      64: Color(0xFF3A9CC5),
      128: Color(0xFFB8D4E3),
      256: Color(0xFF8BB8D0),
      512: Color(0xFF6BA3C2),
      1024: Color(0xFF4A8CB3),
      2048: Color(0xFFC0E0F0),
    },
    textColorLight: Color(0xFF2C6E8A),
    textColorDark: Color(0xFFFFFFFF),
  );

  static const TileTheme aurora = TileTheme(
    id: 'aurora',
    name: 'Aurora',
    description: 'Northern lights palette',
    requiredLevel: 0,
    isPremium: true,
    tileColors: {
      2: Color(0xFFE0F2E9),
      4: Color(0xFFB2DFDB),
      8: Color(0xFF80CBC4),
      16: Color(0xFF4DB6AC),
      32: Color(0xFF26A69A),
      64: Color(0xFF009688),
      128: Color(0xFF7E57C2),
      256: Color(0xFF5C6BC0),
      512: Color(0xFF42A5F5),
      1024: Color(0xFF26C6DA),
      2048: Color(0xFF66BB6A),
    },
    textColorLight: Color(0xFF00695C),
    textColorDark: Color(0xFFFFFFFF),
  );

  static const TileTheme obsidian = TileTheme(
    id: 'obsidian',
    name: 'Obsidian',
    description: 'Dark volcanic glass tones',
    requiredLevel: 0,
    isPremium: true,
    tileColors: {
      2: Color(0xFF37474F),
      4: Color(0xFF455A64),
      8: Color(0xFFD84315),
      16: Color(0xFFE64A19),
      32: Color(0xFFFF5722),
      64: Color(0xFFFF6E40),
      128: Color(0xFFFF3D00),
      256: Color(0xFFDD2C00),
      512: Color(0xFFBF360C),
      1024: Color(0xFFFFAB00),
      2048: Color(0xFFFFD600),
    },
    textColorLight: Color(0xFFCFD8DC),
    textColorDark: Color(0xFFFFFFFF),
  );

  static const List<TileTheme> all = [
    classic,
    neon,
    ocean,
    sunset,
    galaxy,
    monochrome,
    diamond,
    aurora,
    obsidian,
  ];

  static TileTheme? byId(String id) {
    for (final theme in all) {
      if (theme.id == id) return theme;
    }
    return null;
  }

  static TileTheme getById(String id) {
    return byId(id) ?? classic;
  }
}

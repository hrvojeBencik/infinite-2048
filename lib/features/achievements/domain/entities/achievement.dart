import 'package:equatable/equatable.dart';

enum AchievementCategory { progression, skill, collection, streak }

class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final String iconName;
  final double progress;
  final double targetValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.iconName = 'emoji_events',
    this.progress = 0,
    this.targetValue = 1,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progressPercentage =>
      targetValue > 0 ? (progress / targetValue).clamp(0, 1) : 0;

  Achievement copyWith({
    double? progress,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      category: category,
      iconName: iconName,
      progress: progress ?? this.progress,
      targetValue: targetValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'progress': progress,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, progress, isUnlocked];
}

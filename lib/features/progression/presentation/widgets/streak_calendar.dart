import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_profile.dart';

class StreakCalendar extends StatelessWidget {
  final PlayerProfile profile;

  const StreakCalendar({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) {
      final date = today.subtract(Duration(days: 6 - i));
      final isLoggedIn = _wasLoggedInOn(date);
      return _DayCircle(filled: isLoggedIn);
    });

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_fire_department_rounded,
          size: 20,
          color: profile.loginStreak > 0
              ? AppColors.secondary
              : AppColors.textTertiary,
        ),
        const SizedBox(width: 6),
        Text(
          '${profile.loginStreak} day streak',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: profile.loginStreak > 0
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        ...days.map((d) => Padding(
              padding: const EdgeInsets.only(left: 4),
              child: d,
            )),
      ],
    );
  }

  bool _wasLoggedInOn(DateTime date) {
    if (profile.lastLoginDate == null || profile.loginStreak <= 0) return false;
    final last = profile.lastLoginDate!;
    final target = DateTime(date.year, date.month, date.day);
    final lastDate = DateTime(last.year, last.month, last.day);
    if (target.isAfter(lastDate)) return false;
    final diff = lastDate.difference(target).inDays;
    return diff < profile.loginStreak;
  }
}

class _DayCircle extends StatelessWidget {
  final bool filled;

  const _DayCircle({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.secondary : AppColors.surface,
        border: Border.all(
          color: filled ? AppColors.secondary : AppColors.cardBorder,
          width: 1,
        ),
      ),
    );
  }
}

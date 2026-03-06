import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PremiumBadge extends StatelessWidget {
  final double size;

  const PremiumBadge({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size * 0.4, vertical: size * 0.15),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withAlpha(80),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: size * 0.7, color: AppColors.background),
          SizedBox(width: size * 0.15),
          Text(
            'PRO',
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.w800,
              color: AppColors.background,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

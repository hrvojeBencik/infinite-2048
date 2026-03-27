import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ShareScoreCard extends StatelessWidget {
  final int score;
  final int highestTile;
  final String modeName;

  const ShareScoreCard({
    super.key,
    required this.score,
    required this.highestTile,
    required this.modeName,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: 360,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1F3A),
              Color(0xFF0D1128),
              Color(0xFF0A0E21),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withAlpha(100),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(30),
              blurRadius: 40,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App branding
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.secondary],
              ).createShader(bounds),
              child: Text(
                '2048: Merge Quest',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Level badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                modeName.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Score section
            Text(
              'SCORE',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 3.0,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFE0E0FF)],
              ).createShader(bounds),
              child: Text(
                _formatScore(score),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Divider
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withAlpha(80),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Highest tile chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface.withAlpha(200),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.cardBorder.withAlpha(100),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.secondary, Color(0xFFFFA000)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$highestTile',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: highestTile >= 1000 ? 8 : 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.background,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Highest Tile',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // CTA tagline
            Text(
              'Can you beat my score?',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primary],
              ).createShader(bounds),
              child: Text(
                'Play 2048: Merge Quest',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    }
    if (score >= 10000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }
}

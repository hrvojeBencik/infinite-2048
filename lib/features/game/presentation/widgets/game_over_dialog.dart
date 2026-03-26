import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_button.dart';
import 'share_score_card.dart';

class GameOverDialog extends StatefulWidget {
  final int score;
  final int highestTile;
  final int levelNumber;
  final VoidCallback onRetry;
  final VoidCallback onBackToLevels;
  final VoidCallback? onWatchAdToContinue;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.highestTile,
    required this.onRetry,
    required this.onBackToLevels,
    this.onWatchAdToContinue,
    this.levelNumber = 0,
  });

  @override
  State<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<GameOverDialog> {
  bool _isSharing = false;
  final GlobalKey _shareCardKey = GlobalKey();

  Future<void> _shareScore() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      await Future.delayed(Duration.zero); // ensure painted
      final boundary = _shareCardKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/merge_quest_score.png');
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'My 2048 Score',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't share — please try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.error.withAlpha(60)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withAlpha(20),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sentiment_dissatisfied_rounded,
                  size: 56,
                  color: AppColors.error.withAlpha(180),
                ).animate().fadeIn(duration: 300.ms).shake(delay: 300.ms),
                const SizedBox(height: 16),
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatChip(
                        label: 'Score', value: widget.score.toString()),
                    _StatChip(
                        label: 'Best Tile',
                        value: widget.highestTile.toString()),
                  ],
                ),
                const SizedBox(height: 20),
                // Watch ad to continue
                if (widget.onWatchAdToContinue != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AnimatedButton(
                      onPressed: widget.onWatchAdToContinue!,
                      gradient: AppColors.premiumGradient,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_outline_rounded,
                              size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Watch Ad to Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                AnimatedButton(
                  onPressed: widget.onRetry,
                  gradient: AppColors.primaryGradient,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Share Score button
                Semantics(
                  label: _isSharing
                      ? 'Sharing score, please wait...'
                      : 'Share your score',
                  button: !_isSharing,
                  child: GestureDetector(
                    onTap: _isSharing ? null : _shareScore,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withAlpha(180),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.cardBorder.withAlpha(80)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSharing)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textSecondary,
                              ),
                            )
                          else
                            const Icon(Icons.share_rounded,
                                size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          const Text(
                            'Share Score',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: widget.onBackToLevels,
                  child: const Text('Back to Levels'),
                ),
              ],
            ),
          ),
        ),
        // Off-screen ShareScoreCard for RepaintBoundary image capture
        Positioned(
          left: -1000,
          child: ExcludeSemantics(
            child: RepaintBoundary(
              key: _shareCardKey,
              child: ShareScoreCard(
                score: widget.score,
                highestTile: widget.highestTile,
                levelNumber: widget.levelNumber,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class TutorialOverlay extends StatefulWidget {
  final int levelNumber;
  final VoidCallback onComplete;
  final VoidCallback? onDismissStep;

  const TutorialOverlay({
    super.key,
    required this.levelNumber,
    required this.onComplete,
    this.onDismissStep,
  });

  static const Map<int, List<_TutorialStep>> _stepsByLevel = {
    1: [
      _TutorialStep(
        text: 'Swipe in any direction to move all tiles',
        icon: Icons.swipe_rounded,
      ),
      _TutorialStep(
        text: 'Tiles with the same number merge together',
        icon: Icons.call_merge_rounded,
      ),
      _TutorialStep(
        text: 'Reach the target number to win!',
        icon: Icons.emoji_events_rounded,
      ),
    ],
    2: [
      _TutorialStep(
        text: 'Each merge adds to your score',
        icon: Icons.star_rounded,
      ),
      _TutorialStep(
        text: 'Try to merge in corners for bigger combos',
        icon: Icons.grid_view_rounded,
      ),
      _TutorialStep(
        text: 'Watch your move count!',
        icon: Icons.format_list_numbered_rounded,
      ),
    ],
    3: [
      _TutorialStep(
        text: "You've got this! Undos can save you",
        icon: Icons.thumb_up_rounded,
      ),
      _TutorialStep(
        text: 'Tap the undo button to go back one move',
        icon: Icons.undo_rounded,
      ),
      _TutorialStep(
        text: 'Now go conquer the rest!',
        icon: Icons.rocket_launch_rounded,
      ),
    ],
  };

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentStep = 0;

  List<_TutorialStep> get _steps =>
      TutorialOverlay._stepsByLevel[widget.levelNumber] ?? [];

  bool get _hasSteps => _steps.isNotEmpty;

  bool get _isLastStep => _currentStep >= _steps.length - 1;

  void _next() {
    widget.onDismissStep?.call();
    if (_isLastStep) {
      widget.onComplete();
    } else {
      setState(() => _currentStep++);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasSteps) {
      return const SizedBox.shrink();
    }

    final step = _steps[_currentStep];

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            color: AppColors.background.withAlpha(180),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: GlassCard(
            padding: const EdgeInsets.all(28),
            borderRadius: 20,
            blur: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStepIndicators(),
                const SizedBox(height: 24),
                _buildIcon(step),
                const SizedBox(height: 20),
                Text(
                  step.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                _buildButton(),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.15, end: 0, duration: 350.ms, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildStepIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (i) {
        final isActive = i == _currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.textTertiary.withAlpha(120),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildIcon(_TutorialStep step) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withAlpha(180),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(60),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(step.icon, size: 36, color: Colors.white),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _next,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          _isLastStep ? 'Got it!' : 'Next',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TutorialStep {
  final String text;
  final IconData icon;

  const _TutorialStep({
    required this.text,
    required this.icon,
  });
}

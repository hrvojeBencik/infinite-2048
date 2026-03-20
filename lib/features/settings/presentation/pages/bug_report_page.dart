import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

enum _ReportCategory {
  bug('Bug Report', Icons.bug_report_rounded, AppColors.error),
  suggestion('Suggestion', Icons.lightbulb_rounded, AppColors.secondary),
  other('Other', Icons.chat_bubble_outline_rounded, AppColors.primaryLight);

  const _ReportCategory(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

class BugReportPage extends StatefulWidget {
  const BugReportPage({super.key});

  @override
  State<BugReportPage> createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage> {
  final _descriptionController = TextEditingController();
  final _descriptionFocus = FocusNode();
  _ReportCategory _selectedCategory = _ReportCategory.bug;
  bool _sending = false;
  String _appVersion = '';
  String _deviceInfo = '';

  @override
  void initState() {
    super.initState();
    _collectDeviceInfo();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  Future<void> _collectDeviceInfo() async {
    final info = await PackageInfo.fromPlatform();
    final os = Platform.operatingSystem;
    final osVersion = Platform.operatingSystemVersion;
    if (mounted) {
      setState(() {
        _appVersion = '${info.version} (${info.buildNumber})';
        _deviceInfo = '$os $osVersion';
      });
    }
  }

  Future<void> _submit() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      _showSnackBar('Please describe the issue before sending.');
      return;
    }

    setState(() => _sending = true);

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'category': _selectedCategory.name,
        'description': description,
        'appVersion': _appVersion,
        'device': _deviceInfo,
        'platform': Platform.operatingSystem,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showSnackBar('Thank you for your feedback!', isSuccess: true);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to send feedback. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategorySelector()
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.05, end: 0),
                      const SizedBox(height: 24),
                      _buildDescriptionField()
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 80.ms)
                          .slideY(begin: 0.05, end: 0),
                      const SizedBox(height: 24),
                      _buildDeviceInfoCard()
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 160.ms)
                          .slideY(begin: 0.05, end: 0),
                      const SizedBox(height: 32),
                      _buildSubmitButton()
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 240.ms)
                          .slideY(begin: 0.05, end: 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Send Feedback',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('CATEGORY'),
        const SizedBox(height: 10),
        Row(
          children: _ReportCategory.values.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: cat != _ReportCategory.values.last ? 10 : 0,
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cat.color.withAlpha(30)
                          : AppColors.surface.withAlpha(120),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? cat.color.withAlpha(150)
                            : AppColors.cardBorder.withAlpha(100),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          cat.icon,
                          color: isSelected
                              ? cat.color
                              : AppColors.textTertiary,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? cat.color
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('DESCRIPTION'),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.all(4),
          child: TextField(
            controller: _descriptionController,
            focusNode: _descriptionFocus,
            maxLines: 6,
            minLines: 4,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: _selectedCategory == _ReportCategory.bug
                  ? 'What happened? What did you expect?'
                  : _selectedCategory == _ReportCategory.suggestion
                  ? 'What would you like to see improved?'
                  : 'Tell us what\'s on your mind...',
              hintStyle: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary.withAlpha(150),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('AUTO-ATTACHED INFO'),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _infoRow(
                'App Version',
                _appVersion.isEmpty ? '...' : _appVersion,
              ),
              const SizedBox(height: 8),
              _infoRow('Device', _deviceInfo.isEmpty ? '...' : _deviceInfo),
              const SizedBox(height: 8),
              _infoRow('Platform', Platform.operatingSystem),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(60),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _sending ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _sending
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.textPrimary,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Send Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }
}

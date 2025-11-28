import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_theme.dart';

class SuccessModal extends StatelessWidget {
  final VoidCallback onCheckTask;
  final VoidCallback onBackToHome;

  const SuccessModal({super.key, required this.onCheckTask, required this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(AppRadius.xl)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Illustration
            SvgPicture.asset('images/new-task-added.svg', width: 100, height: 100),

            const SizedBox(height: AppSpacing.lg),

            // Title
            Text('New task Added', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),

            const SizedBox(height: AppSpacing.sm),

            // Description
            Text(
              'You can now begin working on the newly added task',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCheckTask,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
                    ),
                    child: Text('Check task', style: AppTextStyles.button.copyWith(color: AppColors.textPrimary)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onBackToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPurple,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
                      elevation: 4,
                    ),
                    child: Text('Back to home', style: AppTextStyles.button.copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessModal(onCheckTask: () => Navigator.of(context).pop(true), onBackToHome: () => Navigator.of(context).pop(false)),
    );
  }
}

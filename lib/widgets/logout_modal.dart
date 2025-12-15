import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_theme.dart';
import '../services/supabase_service.dart';
import '../providers/task_provider.dart';
import '../providers/profile_provider.dart';
import '../screens/sign_in_screen.dart';

class LogoutModal extends StatelessWidget {
  const LogoutModal({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const LogoutModal(),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Clear provider data first
      Provider.of<TaskProvider>(context, listen: false).clearTasks();
      Provider.of<ProfileProvider>(context, listen: false).clearProfile();
      
      // Sign out from Supabase
      await supabase.auth.signOut();
      
      if (context.mounted) {
        // Navigate to login screen
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Illustration
            SvgPicture.asset('images/logout-modal.svg', width: 100, height: 100),

            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary, fontFamily: AppTextStyles.fontFamily),
            ),
            const SizedBox(height: 12),

            // Content
            const Text(
              'You will be logged out of your account and need to log back in to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: AppTextStyles.fontFamily,
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonDanger, // Red color
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: AppTextStyles.fontFamily),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: AppTextStyles.fontFamily),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

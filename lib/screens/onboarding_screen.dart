import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'home_screen.dart';
import 'sign_in_screen.dart';
import 'signup_screen.dart';
import '../constants/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _navigate(BuildContext context, Widget targetScreen, {bool replace = false}) async {
    // Just navigate without saving preference
    if (context.mounted) {
      if (replace) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground, // --Second-purple-600
      body: Stack(
        children: [
          // Top Right Decorative SVG (CustomPainter)
          Positioned(
            top: -37, // CSS top: -37px
            left: 277, // CSS left: 277px
            child: CustomPaint(
              size: const Size(112, 117), // SVG width/height
              painter: _BackgroundDecorationPainter(),
            ),
          ),

          // Floating Elements Area
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.bottomCenter,
                      child: Transform.scale(
                        scale: 1.1,
                        child: SvgPicture.asset(
                          'images/onboard-pic.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(), // Spacer for the bottom sheet area
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 60),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Placeholder for logo icon if needed, or just text
                      const Text(
                        'FocusBuddy',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600, // 590 in Figma
                          color: AppColors.textDarkPurple, // --Primary-purple-900
                          letterSpacing: -0.32,
                          fontFamily: AppTextStyles.fontFamily,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Title
                  const Text(
                    'Stay Organized and\nStay Productive!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500, // 510 in Figma
                      color: Colors.black,
                      height: 1.28,
                      letterSpacing: -0.32,
                      fontFamily: AppTextStyles.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Description
                  const Text(
                    'Easily manage your daily tasks and stay\nfocused on what matters most.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGrey, // --Monochrome-600
                      height: 1.5,
                      letterSpacing: -0.32,
                      fontFamily: AppTextStyles.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Primary Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _navigate(context, const SignUpScreen(fromOnboarding: true)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPurple, // --Primary-purple-600
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Text(
                        'Get started',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.32,
                          fontFamily: AppTextStyles.fontFamily,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Secondary Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => _navigate(context, const SignInScreen()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: AppColors.borderLighter), // --Monochrome-100
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Text(
                        'Already have an account',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.32,
                          fontFamily: AppTextStyles.fontFamily,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}

class _BackgroundDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Circle 1: opacity="0.24" cx="84" cy="33" r="70" stroke="white" stroke-width="28"
    final paint1 = Paint()
      ..color = Colors.white.withOpacity(0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28;
    
    canvas.drawCircle(const Offset(84, 33), 70, paint1);

    // Circle 2: cx="84" cy="33" r="42" stroke="url(#paint0_linear_5064_6276)" stroke-width="1.16667"
    // Gradient: x1="84" y1="-9" x2="84" y2="75"
    // stop-color="white" stop-opacity="0.52"
    // stop offset="1" stop-color="white" stop-opacity="0.2"
    
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.52),
        Colors.white.withOpacity(0.2),
      ],
      stops: const [0.0, 1.0],
    );

    final rect = Rect.fromCircle(center: const Offset(84, 33), radius: 42);
    final paint2 = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.16667;

    canvas.drawCircle(const Offset(84, 33), 42, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

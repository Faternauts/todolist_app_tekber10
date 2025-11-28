import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_theme.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      body: Stack(
        children: [
          // Background Decoration - Top Right
          Positioned(
            right: -40,
            top: -40,
            child: Opacity(
              opacity: 0.8,
              child: SvgPicture.asset(
                'images/top-bg.svg',
                width: 160,
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Background Decoration - Bottom Left (Aligned with text)
          Positioned(
            top: 150,
            left: -20,
            child: Opacity(
              opacity: 0.8,
              child: SvgPicture.asset(
                'images/left-bg.svg',
                width: 130,
                height: 130,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          // Main Content
          Column(
            children: [
              // Header Area
              const SizedBox(height: 80), // Top padding
              const Center(
                child: Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: -0.32,
                    fontFamily: AppTextStyles.fontFamily,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Please enter your details.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF717171),
                    letterSpacing: -0.32,
                    fontFamily: AppTextStyles.fontFamily,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // White Container (Bottom Sheet Style)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Address Label
                        const Text(
                          'Email address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontFamily: AppTextStyles.fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Email Input
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Enter email address',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9E9E9E),
                              fontFamily: AppTextStyles.fontFamily,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Password Label
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontFamily: AppTextStyles.fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Password Input
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Enter password',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9E9E9E),
                              fontFamily: AppTextStyles.fontFamily,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Forgot Password
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Implement forgot password
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontFamily: AppTextStyles.fontFamily,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Implement sign in logic
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9759C4),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.32,
                                fontFamily: AppTextStyles.fontFamily,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Or sign in with
                        const Center(
                          child: Text(
                            'Or sign in with',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF717171),
                              fontFamily: AppTextStyles.fontFamily,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Google Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Implement Google sign in
                            },
                            icon: Image.network(
                              'https://www.google.com/favicon.ico',
                              width: 20,
                              height: 20,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.g_mobiledata, size: 20, color: Colors.black);
                              },
                            ),
                            label: const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontFamily: AppTextStyles.fontFamily,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFEEEEEE)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Facebook Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Implement Facebook sign in
                            },
                            icon: const Icon(
                              Icons.facebook,
                              size: 20,
                              color: Color(0xFF1877F2),
                            ),
                            label: const Text(
                              'Sign in with Facebook',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontFamily: AppTextStyles.fontFamily,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFEEEEEE)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Sign Up Link
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "You don't have an account? ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  fontFamily: AppTextStyles.fontFamily,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // TODO: Navigate to sign up screen
                                },
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF9759C4),
                                    fontFamily: AppTextStyles.fontFamily,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



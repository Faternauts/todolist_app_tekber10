import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_theme.dart';
import '../services/supabase_service.dart';
import '../providers/task_provider.dart';
import '../providers/profile_provider.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                          obscureText: !_isPasswordVisible,
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF9E9E9E),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9759C4),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              disabledBackgroundColor:
                                  const Color(0xFF9759C4).withOpacity(0.6),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const SignUpScreen()),
                                  );
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

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mohon isi email dan password'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Load user data before navigating
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);

      try {
        await Future.wait([
          taskProvider.loadTasks(),
          profileProvider.loadProfile(),
        ]);
      } catch (e) {
        print('Error loading data after sign in: $e');
      }

      if (!mounted) return;

      // Navigate to home screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Login gagal. Silakan coba lagi.';
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('invalid login credentials') ||
          errorString.contains('invalid_credentials')) {
        errorMessage = 'Email atau password salah';
      } else if (errorString.contains('email not confirmed')) {
        errorMessage = 'Email belum diverifikasi. Cek inbox Anda';
      } else if (errorString.contains('user not found')) {
        errorMessage = 'Akun tidak ditemukan';
      } else if (errorString.contains('network') ||
          errorString.contains('connection')) {
        errorMessage = 'Koneksi internet bermasalah';
      } else if (errorString.contains('too many requests')) {
        errorMessage = 'Terlalu banyak percobaan. Coba lagi nanti';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

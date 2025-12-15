import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/supabase_service.dart';
import '../providers/task_provider.dart';
import '../providers/profile_provider.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final username = _usernameController.text.trim();
    final age = _ageController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Mohon isi semua kolom wajib', isError: true);
      return;
    }

    if (username.length < 3) {
      _showSnackBar('Username minimal 3 karakter', isError: true);
      return;
    }

    if (age.isNotEmpty) {
      final ageNum = int.tryParse(age);
      if (ageNum == null || ageNum < 1 || ageNum > 150) {
        _showSnackBar('Umur tidak valid', isError: true);
        return;
      }
    }

    if (!email.contains('@')) {
      _showSnackBar('Format email tidak valid', isError: true);
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Password minimal 6 karakter', isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Password tidak cocok', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Sign up dengan user metadata (akan digunakan oleh database trigger)
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'age': age.isNotEmpty ? int.parse(age) : null,
        },
      );

      if (response.user != null && mounted) {
        print('✅ User signed up: ${response.user!.email}');
        print('✅ Session: ${response.session != null ? "Active" : "Pending verification"}');
        
        // Check if email confirmation is required
        if (response.session == null) {
          // Email confirmation required - show message
          if (mounted) {
            _showSnackBar('Silakan cek email untuk verifikasi akun', isError: false);
            
            // Navigate back to sign in
            Navigator.of(context).pop();
          }
          return;
        }
        
        // Session is active - proceed to home
        print('✅ Profile will be auto-created by database trigger');
        
        // Wait for session to establish
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Load user data
        if (mounted) {
          final taskProvider = Provider.of<TaskProvider>(context, listen: false);
          final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
          
          try {
            await Future.wait([
              taskProvider.loadTasks(),
              profileProvider.loadProfile(),
            ]);
            print('✅ User data loaded after signup');
          } catch (e) {
            print('⚠️ Warning: Could not load data after signup: $e');
          }
        }
        
        if (mounted) {
          _showSnackBar('Akun berhasil dibuat!', isError: false);
          
          // Navigate to home screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Pendaftaran gagal. Silakan coba lagi.';
        final errorString = e.toString().toLowerCase();

        if (errorString.contains('user already registered') || 
            errorString.contains('already registered')) {
          errorMessage = 'Email sudah terdaftar. Silakan login';
        } else if (errorString.contains('invalid email')) {
          errorMessage = 'Format email tidak valid';
        } else if (errorString.contains('password') && errorString.contains('weak')) {
          errorMessage = 'Password terlalu lemah';
        } else if (errorString.contains('network') || errorString.contains('connection')) {
          errorMessage = 'Koneksi internet bermasalah';
        } else if (errorString.contains('too many requests')) {
          errorMessage = 'Terlalu banyak percobaan. Coba lagi nanti';
        }

        _showSnackBar(errorMessage, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
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

          // Background Decoration - Bottom Left
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
              // Back Button
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Header Area
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Create Account',
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
                  'Sign up to get started.',
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
              
              // White Container
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
                        // Username Label
                        const Text(
                          'Username',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontFamily: AppTextStyles.fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Username Input
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Enter username',
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
                        
                        // Age Label (Optional)
                        const Text(
                          'Age (optional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontFamily: AppTextStyles.fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Age Input
                        TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter age',
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
                          keyboardType: TextInputType.emailAddress,
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
                        const SizedBox(height: 20),
                        
                        // Confirm Password Label
                        const Text(
                          'Confirm Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontFamily: AppTextStyles.fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Confirm Password Input
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Confirm password',
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
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF9E9E9E),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9759C4),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              disabledBackgroundColor: const Color(0xFF9759C4).withOpacity(0.6),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Sign up',
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
                        
                        // Sign In Link
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  fontFamily: AppTextStyles.fontFamily,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  'Sign in',
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
                        const SizedBox(height: 20),
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

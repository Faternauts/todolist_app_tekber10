import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_theme.dart';
import '../services/supabase_service.dart';
import '../providers/task_provider.dart';
import '../providers/profile_provider.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memilih foto: $e', isError: true);
      }
    }
  }

  Future<void> _handleContinue() async {
    final username = _usernameController.text.trim();
    final age = _ageController.text.trim();

    if (username.isEmpty) {
      _showSnackBar('Mohon isi username', isError: true);
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

    setState(() => _isLoading = true);

    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      String? photoUrl;

      // Upload image to Supabase storage if selected
      if (_selectedImage != null) {
        final fileName = '${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        await supabase.storage.from('avatars').upload(
          fileName,
          _selectedImage!,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );

        photoUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
      }

      // Create profile in Supabase
      await supabase.from('profiles').upsert({
        'id': currentUser.id,
        'username': username,
        'age': age.isNotEmpty ? int.parse(age) : null,
        'photo_url': photoUrl,
      });

      // Load user data
      if (mounted) {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
        try {
          await Future.wait([
            taskProvider.loadTasks(),
            profileProvider.loadProfile(),
          ]);
        } catch (e) {
          print(' Warning: Could not load data: $e');
        }
      }

      if (mounted) {
        _showSnackBar('Profile berhasil dibuat!', isError: false);
        
        // Navigate to home screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal membuat profile: $e', isError: true);
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

          // Background Decoration - Left
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

          SafeArea(
            child: Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Main Content Container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Title
                          const Text(
                            'Set Up Your Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: AppTextStyles.fontFamily,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Help us personalize your experience by\nfilling in your details.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: AppTextStyles.fontFamily,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Photo Picker
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: const Color(0xFFE8D5F2),
                                  backgroundImage: _selectedImage != null
                                      ? FileImage(_selectedImage!)
                                      : null,
                                  child: _selectedImage == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Color(0xFF9759C4),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF9759C4), width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Color(0xFF9759C4),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Username field
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Username',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontFamily: AppTextStyles.fontFamily,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: 'Enter your username',
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

                          // Age field
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Age',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontFamily: AppTextStyles.fontFamily,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter your age',
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
                          const SizedBox(height: 40),

                          // Continue button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleContinue,
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
                                      'Continue',
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

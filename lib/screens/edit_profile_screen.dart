import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_theme.dart';
import '../providers/profile_provider.dart';
import '../services/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  String? _currentPhotoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    _usernameController.text = profile.name;
    _ageController.text = profile.age?.toString() ?? '';
    _currentPhotoUrl = profile.photoPath;
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih foto: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final username = _usernameController.text.trim();
    final age = _ageController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username tidak boleh kosong')),
      );
      return;
    }

    if (username.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username minimal 3 karakter')),
      );
      return;
    }

    if (age.isNotEmpty) {
      final ageNum = int.tryParse(age);
      if (ageNum == null || ageNum < 1 || ageNum > 150) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Umur tidak valid')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      String? photoUrl = _currentPhotoUrl;

      // Upload image to Supabase storage if selected
      if (_selectedImage != null) {
        final currentUser = supabase.auth.currentUser;
        if (currentUser != null) {
          final fileName = '${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final filePath = '$fileName';

          // Delete old avatar if exists
          if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
            try {
              final oldFileName = _currentPhotoUrl!.split('/').last;
              await supabase.storage.from('avatars').remove([oldFileName]);
            } catch (e) {
              print(' Could not delete old avatar: $e');
            }
          }

          // Upload new avatar
          await supabase.storage.from('avatars').upload(
                filePath,
                _selectedImage!,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  upsert: true,
                ),
              );

          // Get public URL
          photoUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
        }
      }

      // Update profile in provider
      if (mounted) {
        await Provider.of<ProfileProvider>(context, listen: false).updateProfile(
          username,
          age.isNotEmpty ? int.parse(age) : null,
          photoUrl,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Edit profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background decoration
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
          
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // AppBar spacer
                const SizedBox(height: 20),
                
                // Main White Container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          // Avatar
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: _selectedImage != null
                                      ? FileImage(_selectedImage!)
                                      : (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty
                                          ? NetworkImage(_currentPhotoUrl!)
                                          : null) as ImageProvider?,
                                  child: (_selectedImage == null && (_currentPhotoUrl == null || _currentPhotoUrl!.isEmpty))
                                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                      : null,
                                ),
                                // Overlay with camera icon centered
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
              
                          // Username field
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
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
                              hintText: 'Enter username',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: AppColors.priorityLow,
                                fontFamily: AppTextStyles.fontFamily,
                              ),
                              filled: true,
                              fillColor: Colors.white, 
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.borderLighter),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.borderLighter),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.primaryPurple),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
              
                          // Age field
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Age (optional)',
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
                              hintText: 'Enter age',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: AppColors.priorityLow,
                                fontFamily: AppTextStyles.fontFamily,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.borderLighter),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.borderLighter),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.primaryPurple),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          // Spacer to push button to bottom if needed, or just bottom padding
                          const SizedBox(height: 20),
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
      // Floating Save Button at the bottom
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              disabledBackgroundColor: AppColors.primaryPurple.withOpacity(0.6),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppTextStyles.fontFamily,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

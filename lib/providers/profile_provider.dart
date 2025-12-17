import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';

class ProfileProvider with ChangeNotifier {
  UserProfile _profile = UserProfile(name: 'User');
  bool _isLoading = false;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;

  // Clear profile (for logout)
  void clearProfile() {
    _profile = UserProfile(name: 'User');
    notifyListeners();
  }

  // Load profile from Supabase
  Future<void> loadProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();

      if (response != null) {
        _profile = UserProfile(
          name: response['username'] ??
              currentUser.email?.split('@')[0] ??
              'User',
          photoPath: response['photo_url'],
          age: response['age'],
        );
      } else {
        // Profile tidak ada, buat yang baru
        await _createProfile();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
<<<<<<< HEAD
      print('Error loading profile: $e');
=======
>>>>>>> 0b9244827c750d285f69e65a618617536c43a3cf
      // Tidak throw error supaya app tetap jalan
    }
  }

  // Create new profile
  Future<void> _createProfile() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      final username = currentUser.email?.split('@')[0] ?? 'User';

      await supabase.from('profiles').insert({
        'id': currentUser.id,
        'username': username,
        'age': null,
        'photo_url': null,
      });

      _profile = UserProfile(name: username);
    } catch (e) {
      print('Error creating profile: $e');
    }
  }

  // Update profile
  Future<void> updateProfile(String name, int? age, String? photoPath) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      _profile.name = name;
      _profile.age = age;
      if (photoPath != null) {
        _profile.photoPath = photoPath;
      }

      await supabase.from('profiles').upsert({
        'id': currentUser.id,
        'username': name,
        'age': age,
        'photo_url': photoPath,
      });

      notifyListeners();
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
}

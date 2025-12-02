import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileProvider with ChangeNotifier {
  UserProfile _profile = UserProfile(name: 'Kristin W');

  UserProfile get profile => _profile;

  // Update profile
  Future<void> updateProfile(String name, String? photoPath) async {
    _profile.name = name;
    if (photoPath != null) {
      _profile.photoPath = photoPath;
    }
    await _saveProfile();
    notifyListeners();
  }

  // Save profile to SharedPreferences
  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile', jsonEncode(_profile.toJson()));
  }

  // Load profile from SharedPreferences
  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileString = prefs.getString('profile');
    if (profileString != null) {
      _profile = UserProfile.fromJson(jsonDecode(profileString));
      notifyListeners();
    }
  }
}

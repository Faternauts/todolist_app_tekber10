class UserProfile {
  String name;
  String? photoPath;

  UserProfile({required this.name, this.photoPath});

  Map<String, dynamic> toJson() {
    return {'name': name, 'photoPath': photoPath};
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(name: json['name'], photoPath: json['photoPath']);
  }
}

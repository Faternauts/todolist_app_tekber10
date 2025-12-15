class UserProfile {
  String name;
  String? photoPath;
  int? age;

  UserProfile({required this.name, this.photoPath, this.age});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'photoPath': photoPath,
      'age': age,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      photoPath: json['photoPath'],
      age: json['age'],
    );
  }
}

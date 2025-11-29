class UserProfile {
  String name;
  String email;
  String preference; // work, school, personal, etc
  List<String> plannerFor; // notifications, task list, to do list, etc
  String? photoPath;

  UserProfile({
    required this.name,
    this.email = '',
    this.preference = 'personal',
    List<String>? plannerFor,
    this.photoPath,
  }) : plannerFor = plannerFor ?? ['notifications', 'task list'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'preference': preference,
      'plannerFor': plannerFor,
      'photoPath': photoPath,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      preference: json['preference'] ?? 'personal',
      plannerFor: json['plannerFor'] != null
          ? List<String>.from(json['plannerFor'])
          : ['notifications', 'task list'],
      photoPath: json['photoPath'],
    );
  }
}

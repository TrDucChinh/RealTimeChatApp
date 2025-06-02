class UserModel {
  final String id;
  final String username;
  final String email;
  final String status;
  final DateTime? lastSeen;
  final Map<String, dynamic> avatar;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.status,
    this.lastSeen,
    required this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      status: json['status'],
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      avatar: json['avatar'] is Map ? json['avatar'] : {'url': json['avatar']},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'status': status,
      'lastSeen': lastSeen?.toIso8601String(),
      'avatar': avatar,
    };
  }

  String get avatarUrl => avatar['url'] ?? '';
}

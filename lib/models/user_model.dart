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
    Map<String, dynamic> avatarData;
    if (json['avatar'] is Map) {
      avatarData = json['avatar'];
    } else if (json['avatar'] is String) {
      avatarData = {'url': json['avatar']};
    } else {
      avatarData = {'url': ''};
    }

    return UserModel(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      status: json['status'],
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      avatar: avatarData,
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

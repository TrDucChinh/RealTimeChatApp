class UserModel {
  final String id;
  final String username;
  final String avatar;
  final String status;
  final String email;

  UserModel({
    required this.id,
    required this.username,
    required this.avatar,
    required this.status,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      username: json['username'],
      avatar: json['avatar'],
      status: json['status'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'avatar': avatar,
      'status': status,
    };
  }
}

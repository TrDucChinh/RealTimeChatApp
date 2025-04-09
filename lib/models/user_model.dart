class UserModel {
  final String id;
  final String username;
  final String avatar;
  final String status;

  UserModel({
    required this.id,
    required this.username,
    required this.avatar,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      username: json['username'],
      avatar: json['avatar'],
      status: json['status'],
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

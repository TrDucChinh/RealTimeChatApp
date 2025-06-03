import 'user_model.dart';

class FriendRequest {
  final String id;
  final UserModel sender;
  final String status;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.sender,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['_id'] as String,
      sender: UserModel.fromJson(json['sender']),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

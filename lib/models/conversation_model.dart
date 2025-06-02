import 'package:chat_app_ttcs/models/message_model.dart';
import 'package:chat_app_ttcs/models/user_model.dart';

class ConversationModel {
  final String id;
  final List<UserModel> participants;
  final String type;
  final String? name; 
  final String? avatar; 
  final String createdBy;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MessageModel? lastMessage;

  ConversationModel({
    required this.id,
    required this.participants,
    required this.type,
    this.name,
    this.avatar,
    required this.createdBy,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['_id'],
      participants: (json['participants'] as List)
          .map((e) => UserModel.fromJson(e))
          .toList(),
      type: json['type'] ?? 'private',
      name: json['name'], 
      avatar: json['avatar'], 
      createdBy: json['createdBy'] ?? '', 
      unreadCount: (json['unreadCount'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'participants': participants.map((e) => e.toJson()).toList(),
      'type': type,
      'name': name, // 🆕
      'avatar': avatar, // 🆕
      'createdBy': createdBy,
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastMessage': lastMessage?.toJson(),
    };
  }

  UserModel getOtherUser(String currentUserId) {
    return participants.firstWhere((user) => user.id != currentUserId);
  }
}
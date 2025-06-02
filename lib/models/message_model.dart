import 'package:chat_app_ttcs/models/user_model.dart';

class Reaction {
  final String userId;
  final String emoji;
  final DateTime createdAt;

  Reaction({
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      userId: json['userId'],
      emoji: json['emoji'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final UserModel? sender;
  final String text;
  final String messageType;
  final List<String> attachments;
  final Map<String, dynamic> status;
  final Map<String, dynamic> emojiData;
  final List<Reaction> reactions;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.sender,
    required this.text,
    required this.messageType,
    required this.attachments,
    required this.status,
    required this.emojiData,
    required this.reactions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final senderIdData = json['senderId'];
    UserModel? sender;
    String senderId;
    
    if (senderIdData == null) {
      senderId = '';
    } else if (senderIdData is Map<String, dynamic>) {
      try {
        sender = UserModel.fromJson(senderIdData);
        senderId = senderIdData['_id'] ?? '';
      } catch (e) {
        print('Error parsing sender data: $e');
        print('Sender data: $senderIdData');
        senderId = senderIdData['_id']?.toString() ?? '';
      }
    } else {
      senderId = senderIdData.toString();
    }

    // Handle attachments
    List<String> attachments = [];
    if (json['attachments'] != null) {
      if (json['attachments'] is List) {
        attachments = (json['attachments'] as List).map((e) {
          if (e is Map<String, dynamic>) {
            return e['url']?.toString() ?? '';
          }
          return e.toString();
        }).toList();
      }
    }

    return MessageModel(
      id: json['_id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: senderId,
      sender: sender,
      text: json['text']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? 'text',
      attachments: attachments,
      status: json['status'] is Map ? json['status'] : {},
      emojiData: json['emojiData'] is Map ? json['emojiData'] : {'isCustomEmoji': false},
      reactions: (json['reactions'] as List?)
          ?.map((e) => Reaction.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'conversationId': conversationId,
      'senderId': sender?.toJson() ?? senderId,
      'text': text,
      'messageType': messageType,
      'attachments': attachments,
      'status': status,
      'emojiData': emojiData,
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final String messageType;
  final List<dynamic> attachments;
  final Map<String, dynamic> status;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.messageType,
    required this.attachments,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'] is String
          ? json['senderId']
          : json['senderId']['_id'],
      text: json['text'],
      messageType: json['messageType'],
      attachments: json['attachments'] ?? [],
      status: json['status'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'text': text,
      'messageType': messageType,
      'attachments': attachments,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

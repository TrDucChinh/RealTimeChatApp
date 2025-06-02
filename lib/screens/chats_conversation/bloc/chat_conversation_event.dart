import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class ChatConversationEvent extends Equatable {
  const ChatConversationEvent();

  @override
  List<Object> get props => [];
}

class LoadMessages extends ChatConversationEvent {
  final String conversationId;

  const LoadMessages(this.conversationId);

  @override
  List<Object> get props => [conversationId];
}

class SendMessage extends ChatConversationEvent {
  final String conversationId;
  final String content;

  const SendMessage(this.conversationId, this.content);

  @override
  List<Object> get props => [conversationId, content];
}

class SendImages extends ChatConversationEvent {
  final String conversationId;
  final List<XFile> images;
  final String? caption;

  const SendImages(this.conversationId, this.images, {this.caption});

  @override
  List<Object> get props => [conversationId, images.map((x) => x.path).toList(), caption ?? ''];
}

class NewMessageReceived extends ChatConversationEvent {
  final Map<String, dynamic> message;

  const NewMessageReceived(this.message);

  @override
  List<Object> get props => [message];
} 
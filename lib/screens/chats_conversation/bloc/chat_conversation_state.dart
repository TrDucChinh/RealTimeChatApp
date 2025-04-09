import 'package:chat_app_ttcs/models/message_model.dart';
import 'package:equatable/equatable.dart';

abstract class ChatConversationState extends Equatable {
  const ChatConversationState();

  @override
  List<Object> get props => [];
}

class ChatConversationInitial extends ChatConversationState {}

class ChatConversationLoading extends ChatConversationState {}

class ChatConversationLoaded extends ChatConversationState {
  final List<MessageModel> messages;
  final String currentUserId;

  const ChatConversationLoaded(this.messages, {required this.currentUserId});

  @override
  List<Object> get props => [messages, currentUserId];
}

class ChatConversationError extends ChatConversationState {
  final String message;

  const ChatConversationError(this.message);

  @override
  List<Object> get props => [message];
} 
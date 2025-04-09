import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class LoadConversations extends ChatEvent {}

class LoadConversationDetail extends ChatEvent {
  final String conversationId;

  const LoadConversationDetail(this.conversationId);

  @override
  List<Object> get props => [conversationId];
}

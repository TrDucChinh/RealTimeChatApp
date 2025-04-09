import 'package:chat_app_ttcs/models/conversation_model.dart';
import 'package:equatable/equatable.dart';


abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ConversationModel> conversations;

  const ChatLoaded(this.conversations);

  @override
  List<Object> get props => [conversations];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}

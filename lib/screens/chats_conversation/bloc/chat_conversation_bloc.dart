import 'dart:convert';
import 'package:chat_app_ttcs/common/helper/helper.dart';
import 'package:chat_app_ttcs/models/message_model.dart';
import 'package:chat_app_ttcs/sample_token.dart';
import 'package:chat_app_ttcs/services/network_service.dart';
import 'package:chat_app_ttcs/services/socket_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'chat_conversation_event.dart';
import 'chat_conversation_state.dart';

class ChatConversationBloc extends Bloc<ChatConversationEvent, ChatConversationState> {
  final NetworkService _networkService;
  late SocketService _socketService;
  final String _conversationId;
  late String _currentUserId;

  ChatConversationBloc({
    required String token,
    required String conversationId,
  })  : _networkService = NetworkService(
          baseUrl: baseUrl2,
          // baseUrl: baseUrl,
          token: token,
        ),
        _conversationId = conversationId,
        super(ChatConversationInitial()) {
    _initSocketService(token);
    _initCurrentUserId(token);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<NewMessageReceived>(_onNewMessageReceived);
  }

  void _initCurrentUserId(String token) {
    _currentUserId = Helper.getUserIdFromToken(token);
  }

  void _initSocketService(String token) {
    _socketService = SocketService(
      baseUrl: baseUrl2,
      // baseUrl: baseUrl,
      token: token,
      conversationId: _conversationId,
    );

    _socketService.onMessageReceived = (message) {
      print('New message received in bloc: ${message.toJson()}');
      add(NewMessageReceived(message.toJson()));
    };
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatConversationState> emit,
  ) async {
    try {
      emit(ChatConversationLoading());
      final response =
          await _networkService.get('/message/${event.conversationId}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('API Response: $data');
        final messages = data.map((e) => MessageModel.fromJson(e)).toList();
        emit(ChatConversationLoaded(messages, currentUserId: _currentUserId));
      } else {
        emit(ChatConversationError('Failed to load messages'));
      }
    } catch (e) {
      emit(ChatConversationError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatConversationState> emit,
  ) async {
    if (state is ChatConversationLoaded) {
      final currentState = state as ChatConversationLoaded;

      try {
        final messageData = {
          'text': event.content,
          'conversationId': _conversationId,
          'senderId': _currentUserId,
          'messageType': 'text',
          'attachments': [],
          'status': {'status': 'sent'},
        };

        // Save to database via REST
        final response = await _networkService.post(
          '/message',
          body: messageData,
        );

        if (response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          print('Send Message Response: $responseData');
          final savedMessage = MessageModel.fromJson(responseData);

          final updatedMessages = List<MessageModel>.from(currentState.messages)
            ..add(savedMessage);
          emit(ChatConversationLoaded(updatedMessages, currentUserId: _currentUserId));
          
          _socketService.sendMessage({
            'text': event.content,
            'conversationId': _conversationId,
            'senderId': _currentUserId,
            'messageType': 'text',
            'attachments': [],
            'status': {'status': 'sent'},
          });
        } else {
          emit(ChatConversationError('Failed to send message'));
        }
      } catch (e) {
        emit(ChatConversationError(e.toString()));
      }
    }
  }

  void _onNewMessageReceived(
    NewMessageReceived event,
    Emitter<ChatConversationState> emit,
  ) {
    if (state is ChatConversationLoaded) {
      final currentState = state as ChatConversationLoaded;
      final newMessage = MessageModel.fromJson(event.message);
      print('Processing new message: ${newMessage.toJson()}');

      if (!currentState.messages.any((msg) => msg.id == newMessage.id)) {
        final updatedMessages = List<MessageModel>.from(currentState.messages)
          ..add(newMessage);
        emit(ChatConversationLoaded(updatedMessages, currentUserId: _currentUserId));
      }
    }
  }

  @override
  Future<void> close() {
    _socketService.dispose();
    return super.close();
  }


}

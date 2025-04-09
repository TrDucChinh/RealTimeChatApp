import 'package:chat_app_ttcs/models/conversation_model.dart';
import 'package:chat_app_ttcs/services/network_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';

import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final NetworkService _networkService;

  ChatBloc({required String token})
      : _networkService = NetworkService(
          baseUrl: 'http://10.0.2.2:3000',
          token: token,
        ),
        super(ChatInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<LoadConversationDetail>(_onLoadConversationDetail);
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      final response = await _networkService.get('/conversations');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final conversations =
            data.map((json) => ConversationModel.fromJson(json)).toList();
        emit(ChatLoaded(conversations));
      } else {
        emit(ChatError('Failed to load conversations'));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadConversationDetail(
    LoadConversationDetail event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      final response =
          await _networkService.get('/conversations/${event.conversationId}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final conversation = ConversationModel.fromJson(data);
        emit(ChatLoaded([conversation]));
      } else {
        emit(ChatError('Failed to load conversation details'));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}

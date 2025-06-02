import 'package:chat_app_ttcs/models/conversation_model.dart';
import 'package:chat_app_ttcs/sample_token.dart';
import 'package:chat_app_ttcs/services/network_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';

import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final NetworkService _networkService;

  ChatBloc({required String token})
      : _networkService = NetworkService(
          // baseUrl: baseUrl, // emulator IP address
          baseUrl: baseUrl2, // Localhost for real device
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
        print('Conversations data: $data');
        final conversations = data.map((json) {
          // Add unreadCount if not present in response
          if (!json.containsKey('unreadCount')) {
            json['unreadCount'] = {};
          }
          return ConversationModel.fromJson(json);
        }).toList();
        emit(ChatLoaded(conversations));
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to load conversations';
        emit(ChatError(errorMessage));
      }
    } catch (e) {
      print('Error loading conversations: $e');
      // The NetworkService now provides user-friendly error messages
      emit(ChatError(e.toString().replaceAll('Exception: ', '')));
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
        // Add unreadCount if not present in response
        if (!data.containsKey('unreadCount')) {
          data['unreadCount'] = {};
        }
        final conversation = ConversationModel.fromJson(data);
        emit(ChatLoaded([conversation]));
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to load conversation details';
        emit(ChatError(errorMessage));
      }
    } catch (e) {
      print('Error loading conversation details: $e');
      // The NetworkService now provides user-friendly error messages
      emit(ChatError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

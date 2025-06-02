import 'dart:convert';
import 'dart:io';
import 'package:chat_app_ttcs/common/helper/helper.dart';
import 'package:chat_app_ttcs/models/message_model.dart';
import 'package:chat_app_ttcs/sample_token.dart';
import 'package:chat_app_ttcs/services/network_service.dart';
import 'package:chat_app_ttcs/services/socket_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'chat_conversation_event.dart';
import 'chat_conversation_state.dart';

class ChatConversationBloc
    extends Bloc<ChatConversationEvent, ChatConversationState> {
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
    on<SendImages>(_onSendImages);
    on<NewMessageReceived>(_onNewMessageReceived);

    print('Ensuring initial socket connection...');
    _socketService.ensureConnection(conversationId);

    print('ChatConversationBloc initialized successfully');
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
      print('New message received in socket: ${message.toJson()}');
      try {
        final messageData = message.toJson();
        // Thêm conversationId nếu chưa có
        if (!messageData.containsKey('conversationId')) {
          messageData['conversationId'] = _conversationId;
        }
        print('Adding NewMessageReceived event to bloc');
        print('Message data to be added: $messageData');
        add(NewMessageReceived(messageData));
        print('NewMessageReceived event added to bloc');
      } catch (e) {
        print('Error processing socket message: $e');
      }
    };
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatConversationState> emit,
  ) async {
    try {
      print('Loading messages for conversation: ${event.conversationId}');
      emit(ChatConversationLoading());

      // Ensure socket is connected and joined to conversation
      print('Ensuring socket connection...');
      _socketService.ensureConnection(event.conversationId);

      final response =
          await _networkService.get('/message/${event.conversationId}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('API Response: $data');
        try {
          final messages = data.map((e) => MessageModel.fromJson(e)).toList();
          print('Successfully loaded ${messages.length} messages');
          emit(ChatConversationLoaded(messages, currentUserId: _currentUserId));
        } catch (parseError) {
          print('Error parsing messages: $parseError');
          print('Problematic data: $data');
          emit(ChatConversationError('Error parsing messages: $parseError'));
        }
      } else {
        print('API Error Response: ${response.body}');
        emit(ChatConversationError(
            'Failed to load messages: ${response.statusCode}'));
      }
    } catch (e, stackTrace) {
      print('Error in _onLoadMessages: $e');
      print('Stack trace: $stackTrace');
      emit(ChatConversationError('Error loading messages: $e'));
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
          emit(ChatConversationLoaded(updatedMessages,
              currentUserId: _currentUserId),);
        } else {
          emit(ChatConversationError('Failed to send message'));
        }
      } catch (e) {
        print('Error sending message: $e');
        emit(ChatConversationError(e.toString()));
      }
    }
  }

  Future<void> _onSendImages(
    SendImages event,
    Emitter<ChatConversationState> emit,
  ) async {
    if (state is ChatConversationLoaded) {
      final currentState = state as ChatConversationLoaded;

      try {
        print('Starting image upload process...');
        print('Number of images to upload: ${event.images.length}');
        
        if (event.images.isEmpty) {
          print('No images to upload');
          emit(ChatConversationError('No images selected'));
          return;
        }

        // Convert XFile to File and validate
        final files = <File>[];
        for (final xFile in event.images) {
          print('Processing image: ${xFile.path}');
          final file = File(xFile.path);
          if (await file.exists()) {
            print('File exists and is valid: ${file.path}');
            files.add(file);
          } else {
            print('File does not exist: ${file.path}');
          }
        }

        if (files.isEmpty) {
          print('No valid files to upload');
          emit(ChatConversationError('No valid images to upload'));
          return;
        }

        print('Files prepared for upload: ${files.length}');
        for (final file in files) {
          print('File path: ${file.path}');
          print('File size: ${await file.length()} bytes');
        }

        // Upload images first
        print('Sending upload request to server...');
        final uploadResponse = await _networkService.uploadFiles(
          '/media/upload-multiple',
          files,
        );
        print('Upload Response Status: ${uploadResponse.statusCode}');
        print('Upload Response Body: ${uploadResponse.body}');

        if (uploadResponse.statusCode == 200) {
          final uploadData = jsonDecode(uploadResponse.body);
          print('Upload data decoded: $uploadData');

          final List<Map<String, dynamic>> uploadedMedia =
              List<Map<String, dynamic>>.from(uploadData);
          print('Processed media data: $uploadedMedia');

          // Tạo message với danh sách attachments đầy đủ
          final messageData = {
            'text': event.caption ?? 'Sent images', 
            'conversationId': _conversationId,
            'senderId': _currentUserId,
            'messageType': 'image',
            'attachments': uploadedMedia,
            'status': {'status': 'sent'},
          };
          print('Prepared message data: $messageData');
          print('Conversation ID: $_conversationId');
          print('Text content: ${messageData['text']}');
          print('Attachments in messages: ${messageData['attachments']}');

          // Validate required fields
          if (messageData['conversationId'] == null || messageData['text'] == null) {
            print('Missing required fields in message data');
            print('Conversation ID present: ${messageData['conversationId'] != null}');
            print('Text present: ${messageData['text'] != null}');
            emit(ChatConversationError('Missing required fields in message'));
            return;
          }

          // Gửi message
          print('Sending message with attachments...');
          print('Request body: ${jsonEncode(messageData)}');
          final response = await _networkService.post(
            '/message',
            body: messageData,
          );
          print('Message send response status: ${response.statusCode}');
          print('Message send response body: ${response.body}');

          if (response.statusCode == 201) {
            final responseData = jsonDecode(response.body);
            print('Message saved successfully: $responseData');
            final savedMessage = MessageModel.fromJson(responseData);

            final updatedMessages =
                List<MessageModel>.from(currentState.messages)
                  ..add(savedMessage);
            emit(ChatConversationLoaded(updatedMessages,
                currentUserId: _currentUserId,),);
            print('State updated with new message');
          } else {
            print('Failed to send message. Status: ${response.statusCode}');
            emit(ChatConversationError('Failed to send images'));
          }
        } else {
          print('Image upload failed. Status: ${uploadResponse.statusCode}');
          print('Error response: ${uploadResponse.body}');
          emit(ChatConversationError('Failed to upload images'));
        }
      } catch (e, stackTrace) {
        print('Error sending images: $e');
        print('Stack trace: $stackTrace');
        emit(ChatConversationError(e.toString()));
      }
    }
  }

  void _onNewMessageReceived(
    NewMessageReceived event,
    Emitter<ChatConversationState> emit,
  ) {
    print('Processing new message event: ${event.message}');
    try {
      // Ensure socket is connected and joined to conversation
      print('Ensuring socket connection for new message...');
      _socketService.ensureConnection(_conversationId);

      if (state is ChatConversationLoaded) {
        final currentState = state as ChatConversationLoaded;
        print(
            'Current state is ChatConversationLoaded with ${currentState.messages.length} messages');

        final newMessage = MessageModel.fromJson(event.message);
        print('Parsed new message: ${newMessage.toJson()}');
        print('New message conversationId: ${newMessage.conversationId}');
        print('Current conversationId: $_conversationId');

        // Kiểm tra xem tin nhắn có thuộc conversation hiện tại không
        if (newMessage.conversationId != _conversationId) {
          print('Message belongs to different conversation, skipping');
          return;
        }

        // Kiểm tra nếu tin nhắn đã tồn tại
        if (!currentState.messages.any((msg) => msg.id == newMessage.id)) {
          print('Adding new message to list');
          final updatedMessages = List<MessageModel>.from(currentState.messages)
            ..add(newMessage);
          print('Emitting new state with ${updatedMessages.length} messages');
          emit(ChatConversationLoaded(updatedMessages,
              currentUserId: _currentUserId));
          print('New state emitted successfully');
        } else {
          print('Message already exists, skipping');
        }
      } else {
        print('State is not ChatConversationLoaded, reloading messages');
        add(LoadMessages(_conversationId));
      }
    } catch (e) {
      print('Error processing new message: $e');
      print('Problematic message data: ${event.message}');
    }
  }

  @override
  Future<void> close() {
    _socketService.dispose();
    return super.close();
  }
}

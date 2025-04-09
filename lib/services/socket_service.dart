import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/message_model.dart';

typedef MessageCallback = void Function(MessageModel message);

class SocketService {
  late IO.Socket _socket;
  final String _baseUrl;
  final String _token;
  final String _conversationId;

  MessageCallback? onMessageReceived;

  SocketService({
    required String baseUrl,
    required String token,
    required String conversationId,
  })  : _baseUrl = baseUrl,
        _token = token,
        _conversationId = conversationId {
    _initSocket();
  }

  void _initSocket() {
    _socket = IO.io(
      _baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $_token'})
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      print('Socket connected');
      _socket.emit('joinConversation', _conversationId);
    });

    _socket.onDisconnect((_) => print('Socket disconnected'));
    _socket.onConnectError((err) => print('Socket connect error: $err'));

    _socket.on('receiveMessage', (data) {
      print('Received message from socket: $data');
      try {
        final message = MessageModel.fromJson(data['message']);
        onMessageReceived?.call(message);
      } catch (e) {
        print('Error parsing message: $e');
      }
    });

    _socket.on('conversationUpdated', (data) {
      print('Conversation updated: $data');
      // Optional: handle update logic here
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    print('Sending message: $message');
    _socket.emit('sendMessage', message);
  }

  void dispose() {
    _socket.disconnect();
    _socket.dispose();
  }
}

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
    print('Initializing socket with baseUrl: $_baseUrl');
    print('ConversationId: $_conversationId');
    print('Token: ${_token.substring(0, 10)}...');

    try {
      // Add /socket.io to baseUrl if not present
      final socketUrl = _baseUrl;
      print('Socket URL: $socketUrl');

      _socket = IO.io(
        _baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({
              'token': _token,
            })
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setTimeout(20000)
            .build(),
      );

      print('Socket instance created, attempting to connect...');
      print('Socket configuration:');
      print('- Transports: websocket, polling');
      print('- Reconnection attempts: 10');
      print('- Reconnection delay: 1000ms');
      print('- Reconnection max delay: 5000ms');
      print('- Timeout: 20000ms');

      // Add connection state change listener
      _socket.onConnect((_) {
        print('Socket connected successfully');
        print('Socket ID: ${_socket.id}');
        print('Joining conversation: $_conversationId');
        _socket.emit('joinConversation', _conversationId);
      });

      _socket.onConnectError((err) {
        print('Socket connect error: $err');
        print('Connection details:');
        print('- Socket URL: $socketUrl');
        print('- Conversation ID: $_conversationId');
        print('- Token: ${_token.substring(0, 10)}...');
        print('- Socket ID: ${_socket.id}');
        print('- Transport: ${_socket.io?.engine?.transport?.name}');
      });

      _socket.onDisconnect((_) {
        print('Socket disconnected');
        print('Attempting to reconnect...');
      });

      _socket.onError((err) {
        print('Socket error occurred: $err');
      });

      _socket.onReconnect((_) {
        print('Socket reconnected');
        print('Rejoining conversation: $_conversationId');
        _socket.emit('joinConversation', _conversationId);
      });

      _socket.onReconnectAttempt((attempt) {
        print('Socket reconnection attempt: $attempt');
      });

      _socket.onReconnectError((err) {
        print('Socket reconnection error: $err');
      });

      _socket.onReconnectFailed((_) {
        print('Socket reconnection failed');
      });

      // Add listener for all events to debug
      _socket.onAny((event, data) {
        print('Socket event received - Event: $event, Data: $data');
      });

      // Listen for new messages
      _socket.on('newMessage', (data) {
        print('New message event received: $data');
        print('Socket state when receiving message:');
        print('- Connected: ${_socket.connected}');
        print('- Socket ID: ${_socket.id}');
        print('- Transport: ${_socket.io?.engine?.transport?.name}');
        _handleNewMessage(data);
      });

      // Listen for message updates
      _socket.on('messageUpdate', (data) {
        print('Message update event received: $data');
        print('Socket state when receiving update:');
        print('- Connected: ${_socket.connected}');
        print('- Socket ID: ${_socket.id}');
        _handleNewMessage(data);
      });

      // Listen for receiveMessage (backup)
      _socket.on('receiveMessage', (data) {
        print('Receive message event received: $data');
        print('Socket state when receiving backup message:');
        print('- Connected: ${_socket.connected}');
        print('- Socket ID: ${_socket.id}');
        _handleNewMessage(data);
      });

      _socket.on('conversationUpdated', (data) {
        print('Conversation updated: $data');
        print('Socket state when conversation updated:');
        print('- Connected: ${_socket.connected}');
        print('- Socket ID: ${_socket.id}');
      });

      // Add ping/pong handlers to check connection
      _socket.on('ping', (_) => print('Ping received'));
      _socket.on('pong', (_) => print('Pong received'));

      // Connect to socket
      print('Connecting to socket...');
      _socket.connect();
      print('Socket connect called');
    } catch (e) {
      print('Error initializing socket: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  void _handleNewMessage(dynamic data) {
    print('Handling new message: $data');
    try {
      if (data is Map<String, dynamic>) {
        // Handle different message formats
        Map<String, dynamic> messageData;
        if (data.containsKey('message')) {
          messageData = data['message'];
        } else {
          messageData = data;
        }

        print('Message data to process: $messageData');
        final message = MessageModel.fromJson(messageData);
        print('Successfully parsed message: ${message.toJson()}');
        print('Calling onMessageReceived callback');
        onMessageReceived?.call(message);
        print('onMessageReceived callback completed');
      } else {
        print('Invalid message format: $data');
      }
    } catch (e) {
      print('Error handling new message: $e');
      print('Problematic data: $data');
    }
  }

  void ensureConnection(String conversationId) {
    print('Ensuring socket connection for conversation: $conversationId');
    print('Current socket state:');
    print('- Connected: ${_socket.connected}');
    print('- Disconnected: ${_socket.disconnected}');

    if (!_socket.connected) {
      print('Socket not connected, attempting to connect...');
      try {
        _socket.connect();
        print('Socket connect called, waiting for connection...');
      } catch (e) {
        print('Error connecting socket: $e');
        print('Stack trace: ${StackTrace.current}');
      }
    } else {
      print('Socket already connected');
    }

    // Always rejoin the conversation to ensure we're listening
    print('Joining conversation: $conversationId');
    try {
      _socket.emit('joinConversation', conversationId);
      print('Join conversation event emitted');
    } catch (e) {
      print('Error joining conversation: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    print('Sending message through socket: $message');
    try {
      _socket.emit('sendMessage', message);
      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void dispose() {
    _socket.disconnect();
    _socket.dispose();
  }
}

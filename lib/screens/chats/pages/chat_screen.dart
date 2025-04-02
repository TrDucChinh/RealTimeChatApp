import 'package:chat_app_ttcs/screens/chats/widgets/app_bar_chat.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(),
      backgroundColor: Colors.white,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate using GoRouter
            context.push('/chat/123'); // or context.go('/chat/123')
          },
          child: Text('Chat Screen'),
        ),
      ),
    );
  }
}

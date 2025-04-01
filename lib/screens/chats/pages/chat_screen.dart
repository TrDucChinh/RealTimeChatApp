import 'package:chat_app_ttcs/screens/chats/widgets/app_bar_chat.dart';
import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      // appBar: AppBarChats(),
      appBar: ChatAppBar(),
      body: Center(
        child: Text(
          'Chat Screen',
          
        ),
      ),
    );
  }
}
import 'package:chat_app_ttcs/screens/chats/widgets/app_bar_chat.dart';
import 'package:chat_app_ttcs/screens/chats/widgets/conversation_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 100), // Add padding for AppBar
        itemCount: 5, // Số lượng item
        separatorBuilder: (context, index) =>
           SizedBox(height: 24.h), // Khoảng cách giữa các item
        itemBuilder: (context, index) {
          final items = [
            ConversationItem(
              imageUrl:
                  'https://images.unsplash.com/photo-1633332755192-727a05c4013d',
              name: 'David Wayne',
              lastMessage: 'Thanks a bunch! Have a great day! 😊',
              time: '10:25',
              unReadCount: '2',
            ),
            ConversationItem(
              imageUrl:
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
              name: 'Sarah Johnson',
              lastMessage: 'See you tomorrow at the meeting!',
              time: '22:20  09/05',
              unReadCount: '1',
            ),
            ConversationItem(
              imageUrl:
                  'https://images.unsplash.com/photo-1599566150163-29194dcaad36',
              name: 'Michael Chen',
              lastMessage: 'The project looks great! 👍',
              time: '08:45',
              unReadCount: '3',
            ),
            ConversationItem(
              imageUrl:
                  'https://images.unsplash.com/photo-1580489944761-15a19d654956',
              name: 'Emma Wilson',
              lastMessage: 'Can you send me the files?',
              time: 'Yesterday',
              unReadCount: '5',
            ),
            GestureDetector(
              onTap: () {
                context.push('/chat/123');
              },
              child: ConversationItem(
                imageUrl:
                    'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
                name: 'James Smith',
                lastMessage: "Let's discuss the details",
                time: 'Yesterday',
                unReadCount: '0',
              ),
            ),
          ];
          return items[index];
        },
      ),
    );
  }
}

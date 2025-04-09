import 'package:chat_app_ttcs/screens/chats/bloc/chat_bloc.dart';
import 'package:chat_app_ttcs/screens/chats/bloc/chat_event.dart';
import 'package:chat_app_ttcs/screens/chats/widgets/app_bar_chat.dart';
import 'package:chat_app_ttcs/screens/chats/widgets/conversation_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/utils/app_colors.dart';
import '../bloc/chat_state.dart';

class ChatsScreen extends StatelessWidget {
  final String token;

  const ChatsScreen({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(token: token)..add(LoadConversations()),
      child: Scaffold(
        appBar: ChatAppBar(),
        backgroundColor: AppColors.white,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is ChatError) {
              return Center(child: Text(state.message));
            }
            
            if (state is ChatLoaded) {
              return ListView.separated(
                padding: const EdgeInsets.only(top: 100),
                itemCount: state.conversations.length,
                separatorBuilder: (context, index) => SizedBox(height: 24.h),
                itemBuilder: (context, index) {
                  final conversation = state.conversations[index];
                  return GestureDetector(
                    onTap: () {
                      context.push('/chat/${conversation.id}');
                    },
                    child: ConversationItem(
                      conversation: conversation,
                      currentUserId: '67f61de4128812c84510d101',
                    ),
                  );
                },
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

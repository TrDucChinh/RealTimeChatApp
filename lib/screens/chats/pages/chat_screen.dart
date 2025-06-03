import 'package:chat_app_ttcs/common/helper/helper.dart';
import 'package:chat_app_ttcs/screens/chats/bloc/chat_bloc.dart';
import 'package:chat_app_ttcs/screens/chats/bloc/chat_event.dart';
import 'package:chat_app_ttcs/screens/chats/widgets/app_bar_chat.dart';
import 'package:chat_app_ttcs/screens/chats/widgets/conversation_item.dart';
import 'package:chat_app_ttcs/screens/chats_conversation/pages/chat_conversation_screen.dart';
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
        appBar: ChatAppBar(token: token),
        backgroundColor: AppColors.white,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ChatError) {
              final errorMessage = state.message;
              print('Error: $errorMessage');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(errorMessage),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ChatBloc>().add(LoadConversations());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
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
                      final conversationId = conversation.id.toString();
                      context.pushNamed(
                        'chatConversation',
                        pathParameters: {'id': conversationId},
                        extra: ChatConversationParams(
                          conversation: conversation,
                          token: token,
                        ),
                      );
                    },
                    child: ConversationItem(
                      conversation: conversation,
                      currentUserId: Helper.getUserIdFromToken(token),
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

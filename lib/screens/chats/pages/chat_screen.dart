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

class ChatsScreen extends StatefulWidget {
  final String token;

  const ChatsScreen({
    super.key,
    required this.token,
  });

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc(token: widget.token)..add(LoadConversations());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('ChatsScreen didChangeDependencies called');
    _chatBloc.add(LoadConversations());
  }

  @override
  void didUpdateWidget(ChatsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('ChatsScreen didUpdateWidget called');
    _chatBloc.add(LoadConversations());
  }

  @override
  void dispose() {
    _chatBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: PopScope(
        onPopInvoked: (didPop) {
          if (didPop) {
            print('ChatsScreen PopScope onPopInvoked');
            _chatBloc.add(LoadConversations());
          }
        },
        child: Scaffold(
          appBar: ChatAppBar(token: widget.token),
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
                          _chatBloc.add(LoadConversations());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is ChatLoaded) {
                print('ChatsScreen loaded with ${state.conversations.length} conversations');
                return ListView.separated(
                  padding: const EdgeInsets.only(top: 100),
                  itemCount: state.conversations.length,
                  separatorBuilder: (context, index) => SizedBox(height: 24.h),
                  itemBuilder: (context, index) {
                    final conversation = state.conversations[index];
                    return GestureDetector(
                      onTap: () async {
                        final conversationId = conversation.id.toString();
                        await context.pushNamed(
                          'chatConversation',
                          pathParameters: {'id': conversationId},
                          extra: ChatConversationParams(
                            conversation: conversation,
                            token: widget.token,
                          ),
                        );
                        print('Returning from chat conversation');
                        _chatBloc.add(LoadConversations());
                      },
                      child: ConversationItem(
                        conversation: conversation,
                        currentUserId: Helper.getUserIdFromToken(widget.token),
                      ),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

import 'package:chat_app_ttcs/screens/chats_conversation/widgets/message_item.dart';
import 'package:chat_app_ttcs/screens/chats_conversation/widgets/title_conversion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/scheduler.dart';

import '../../../config/theme/utils/app_colors.dart';
import '../../../models/conversation_model.dart';
import '../widgets/app_bar.dart';
import '../bloc/chat_conversation_bloc.dart';
import '../bloc/chat_conversation_event.dart';
import '../bloc/chat_conversation_state.dart';

class ChatConversationParams {
  final ConversationModel conversation;
  final String token;

  ChatConversationParams({
    required this.conversation,
    required this.token,
  });
}

class ChatConversationScreen extends StatelessWidget {
  const ChatConversationScreen({
    super.key,
    required this.conversationId,
    required this.conversation,
    required this.token,
  });

  final String conversationId;
  final ConversationModel conversation;
  final String token;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatConversationBloc(
        token: token,
        conversationId: conversationId,
      )..add(LoadMessages(conversationId)),
      child: _ChatConversationContent(
        conversation: conversation,
      ),
    );
  }
}

class _ChatConversationContent extends StatefulWidget {
  const _ChatConversationContent({
    required this.conversation,
  });
  final ConversationModel conversation;

  @override
  State<_ChatConversationContent> createState() => _ChatConversationContentState();
}

class _ChatConversationContentState extends State<_ChatConversationContent> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    context.read<ChatConversationBloc>().add(
          SendMessage(widget.conversation.id, _messageController.text.trim()),
        );
    _messageController.clear();

    // Delay nhẹ để chắc chắn đã build xong
    Future.delayed(Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe khi bàn phím bật lên → cuộn xuống cuối
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MediaQuery.of(context).viewInsets.bottom > 0) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: ChatConversationAppBar(),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: TitleConversion(conversation: widget.conversation),
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: Container(
              color: AppColors.neutral_50,
              child: BlocBuilder<ChatConversationBloc, ChatConversationState>(
                builder: (context, state) {
                  if (state is ChatConversationLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatConversationError) {
                    return Center(child: Text(state.message));
                  }

                  if (state is ChatConversationLoaded) {
                    // Scroll ngay sau khi render xong frame
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return ListView.separated(
                      controller: _scrollController,
                      padding: EdgeInsets.only(bottom: 16.h, top: 8.h),
                      itemCount: state.messages.length,
                      separatorBuilder: (context, index) => SizedBox(height: 8.h),
                      itemBuilder: (context, index) {
                        final msg = state.messages[index];
                        return MessageItem(
                          message: msg,
                          isSender: msg.senderId == state.currentUserId,
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            height: 50.h,
            decoration: BoxDecoration(
              color: AppColors.neutral_50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.neutral_300,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

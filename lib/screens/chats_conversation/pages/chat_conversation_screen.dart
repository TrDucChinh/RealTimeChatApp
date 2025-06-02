import 'package:chat_app_ttcs/screens/chats_conversation/widgets/message_item.dart';
import 'package:chat_app_ttcs/screens/chats_conversation/widgets/title_conversion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme/utils/app_colors.dart';
import '../../../models/conversation_model.dart';
import '../../../common/helper/helper.dart';
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
    print('Building ChatConversationScreen');
    print('ConversationId: $conversationId');
    return BlocProvider(
      create: (context) {
        print('Creating ChatConversationBloc');
        final bloc = ChatConversationBloc(
          token: token,
          conversationId: conversationId,
        );
        print('Adding LoadMessages event');
        bloc.add(LoadMessages(conversationId));
        return bloc;
      },
      child: _ChatConversationContent(
        conversation: conversation,
        token: token,
      ),
    );
  }
}

class _ChatConversationContent extends StatefulWidget {
  const _ChatConversationContent({
    required this.conversation,
    required this.token,
  });
  final ConversationModel conversation;
  final String token;

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
    print('ConversationID: ${widget.conversation.id}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MediaQuery.of(context).viewInsets.bottom > 0) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: ChatConversationAppBar(),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: BlocListener<ChatConversationBloc, ChatConversationState>(
        listener: (context, state) {
          print('BlocListener received state change: ${state.runtimeType}');
          if (state is ChatConversationLoaded) {
            print('State is ChatConversationLoaded with ${state.messages.length} messages');
            // Scroll xuống cuối khi có tin nhắn mới
            Future.delayed(Duration(milliseconds: 100), _scrollToBottom);
          }
        },
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: TitleConversion(
                conversation: widget.conversation,
                currentUserId: Helper.getUserIdFromToken(widget.token),
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: Container(
                color: AppColors.neutral_50,
                child: BlocBuilder<ChatConversationBloc, ChatConversationState>(
                  buildWhen: (previous, current) {
                    print('BlocBuilder buildWhen called');
                    print('Previous state: ${previous.runtimeType}');
                    print('Current state: ${current.runtimeType}');
                    
                    // Luôn rebuild khi state thay đổi
                    if (current is ChatConversationLoaded) {
                      print('Current messages count: ${current.messages.length}');
                      if (previous is ChatConversationLoaded) {
                        print('Previous messages count: ${previous.messages.length}');
                        // So sánh nội dung tin nhắn thay vì chỉ so sánh số lượng
                        final hasNewMessages = current.messages.length > previous.messages.length ||
                            current.messages.any((msg) => !previous.messages.any((prevMsg) => prevMsg.id == msg.id));
                        print('Has new messages: $hasNewMessages');
                        return hasNewMessages;
                      }
                      return true;
                    }
                    return true;
                  },
                  builder: (context, state) {
                    print('BlocBuilder builder called with state: ${state.runtimeType}');
                    if (state is ChatConversationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is ChatConversationError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.message),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: () {
                                context.read<ChatConversationBloc>().add(
                                      LoadMessages(widget.conversation.id),
                                    );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is ChatConversationLoaded) {
                      print('Building ListView with ${state.messages.length} messages');
                      return ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.only(bottom: 16.h, top: 8.h),
                        itemCount: state.messages.length,
                        separatorBuilder: (context, index) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final msg = state.messages[index];
                          print('Building message item: ${msg.id}');
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
      ),
    );
  }
}

import 'package:chat_app_ttcs/screens/chats_conversation/widgets/message_item.dart';
import 'package:chat_app_ttcs/screens/chats_conversation/widgets/title_conversion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../config/theme/utils/app_colors.dart';
import '../../../models/conversation_model.dart';
import '../../../models/message_model.dart';
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
  final ImagePicker _picker = ImagePicker();
  static const int maxImages = 10;
  List<XFile> _selectedImages = [];
  XFile? _selectedVideo;

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

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5), // Giới hạn video 5 phút
      );
      if (video != null) {
        setState(() {
          _selectedVideo = video;
          _selectedImages.clear(); // Clear images when video is selected
        });
        print('Video picked: ${video.path}');
      }
    } catch (e) {
      print('Error picking video: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage();
        if (images.isNotEmpty) {
          // Limit to maxImages
          final selectedImages = images.take(maxImages).toList();
          setState(() {
            _selectedImages = List<XFile>.from(selectedImages);
            _selectedVideo = null; // Clear video when images are selected
          });
          print('Selected ${selectedImages.length} images from gallery:');
          for (var image in selectedImages) {
            print('Gallery image path: ${image.path}');
          }
        }
      } else {
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          setState(() {
            _selectedImages = [image];
            _selectedVideo = null; // Clear video when image is selected
          });
          print('Camera image picked: ${image.path}');
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Widget _buildMediaPreview() {
    if (_selectedImages.isEmpty && _selectedVideo == null) return const SizedBox.shrink();

    return Container(
      height: 100.h,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length + (_selectedVideo != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (_selectedVideo != null && index == 0) {
            return Stack(
              children: [
                Container(
                  width: 100.w,
                  height: 100.h,
                  margin: EdgeInsets.only(right: 8.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: Colors.black,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 40.w,
                        color: Colors.white,
                      ),
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Text(
                          'Video',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedVideo = null;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          final imageIndex = _selectedVideo != null ? index - 1 : index;
          return Stack(
            children: [
              Container(
                width: 100.w,
                height: 100.h,
                margin: EdgeInsets.only(right: 8.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  image: DecorationImage(
                    image: FileImage(File(_selectedImages[imageIndex].path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImages.removeAt(imageIndex);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMediaPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn ảnh từ thư viện (tối đa 10 ảnh)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Chọn video từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Quay video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty && _selectedImages.isEmpty && _selectedVideo == null) return;

    print('Sending message with ${_selectedImages.length} images and ${_selectedVideo != null ? "1 video" : "no video"}');
    print('Message text: ${_messageController.text.trim()}');

    if (_selectedVideo != null) {
      print('Sending video...');
      context.read<ChatConversationBloc>().add(
            SendVideo(
              widget.conversation.id,
              _selectedVideo!,
              caption: _messageController.text.trim(),
            ),
          );
    } else if (_selectedImages.isNotEmpty) {
      print('Preparing to send images...');
      final imagesToSend = List<XFile>.from(_selectedImages);
      context.read<ChatConversationBloc>().add(
            SendImages(
              widget.conversation.id,
              imagesToSend,
              caption: _messageController.text.trim(),
            ),
          );
    } else {
      print('Sending text message only');
      context.read<ChatConversationBloc>().add(
            SendMessage(widget.conversation.id, _messageController.text.trim()),
          );
    }

    _messageController.clear();
    setState(() {
      _selectedImages.clear();
      _selectedVideo = null;
    });

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
              child: Column(
                children: [
                  _buildMediaPreview(),
                  Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: AppColors.neutral_50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _showMediaPickerOptions,
                          icon: const Icon(Icons.add_photo_alternate),
                          color: AppColors.neutral_500,
                        ),
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

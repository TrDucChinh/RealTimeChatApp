import 'package:chat_app_ttcs/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_conversation_bloc.dart';
import '../bloc/chat_conversation_event.dart';
import 'message_avatar.dart';
import 'message_content.dart';
import 'message_time.dart';
import 'react_menu.dart';

class MessageItem extends StatefulWidget {
  const MessageItem({
    super.key,
    required this.message,
    required this.isSender,
  });

  final MessageModel message;
  final bool isSender;

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  String? _selectedReaction;

  final List<String> _reactions = ['❤️', '👍', '😂', '😮', '😢', '🙏'];

  @override
  void initState() {
    super.initState();
    if (widget.message.messageType == 'video' &&
        widget.message.attachments.isNotEmpty) {
      _initializeVideo();
    }
    _updateSelectedReaction();
  }

  @override
  void didUpdateWidget(MessageItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.id != widget.message.id) {
      _updateSelectedReaction();
    }
  }

  void _updateSelectedReaction() {
    if (widget.message.reactions.isNotEmpty) {
      setState(() {
        _selectedReaction = widget.message.reactions.first.emoji;
      });
    } else {
      setState(() {
        _selectedReaction = null;
      });
    }
  }

  Future<void> _initializeVideo() async {
    try {
      final videoUrl = widget.message.attachments.first;
      if (videoUrl.startsWith('/')) {
        _videoController = VideoPlayerController.file(File(videoUrl));
      } else {
        _videoController = VideoPlayerController.network(
          videoUrl,
          httpHeaders: {
            'Range': 'bytes=0-',
            'Accept': '*/*',
            'Connection': 'keep-alive',
          },
          formatHint: VideoFormat.hls,
        );
      }

      await _videoController?.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Video initialization timed out');
        },
      );

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isVideoError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVideoError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _handleReaction(String reaction) {
    setState(() {
      _selectedReaction = reaction;
    });
    context.read<ChatConversationBloc>().add(
          AddReaction(widget.message.id, reaction),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment:
            widget.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isSender) ...[
            MessageAvatar(avatarUrl: widget.message.sender?.avatarUrl),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: widget.isSender
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                MessageContent(
                  message: widget.message,
                  isSender: widget.isSender,
                  selectedReaction: _selectedReaction,
                  onLongPress: () => _showReactionMenu(context),
                ),
                SizedBox(height: _selectedReaction != null ? 16.h : 4.h),
                MessageTime(time: widget.message.createdAt),
              ],
            ),
          ),
          if (widget.isSender) ...[
            SizedBox(width: 8.w),
            MessageAvatar(avatarUrl: widget.message.sender?.avatarUrl),
          ],
        ],
      ),
    );
  }

  void _showReactionMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return ReactionMenu(
          position: position,
          reactions: _reactions,
          onReactionSelected: (reaction) {
            _handleReaction(reaction);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
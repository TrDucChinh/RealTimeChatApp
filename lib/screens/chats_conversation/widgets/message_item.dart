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
  bool _isVideoLoading = false;
  String? _selectedReaction;
  bool _isPlaying = false;
  bool _isVideoEnded = false;

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
      if (widget.message.messageType == 'video' &&
          widget.message.attachments.isNotEmpty) {
        _initializeVideo();
      }
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
    if (_videoController != null) {
      await _videoController!.dispose();
    }

    setState(() {
      _isVideoLoading = true;
      _isVideoError = false;
      _isVideoInitialized = false;
      _isVideoEnded = false;
    });

    try {
      final videoUrl = widget.message.attachments.first;
      print('Initializing video with URL: $videoUrl');
      
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
        );
      }

      await _videoController?.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Video initialization timed out');
        },
      );

      // Add listener for video completion
      _videoController?.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isVideoError = false;
          _isVideoLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _isVideoError = true;
          _isVideoLoading = false;
        });
      }
    }
  }

  void _videoListener() {
    if (_videoController != null) {
      // Check if video has ended
      if (_videoController!.value.position >= _videoController!.value.duration) {
        setState(() {
          _isVideoEnded = true;
          _isPlaying = false;
        });
      }
    }
  }

  void _replayVideo() {
    if (_videoController != null) {
      _videoController!.seekTo(Duration.zero);
      _videoController!.play();
      setState(() {
        _isVideoEnded = false;
        _isPlaying = true;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController != null) {
      if (_isVideoEnded) {
        _replayVideo();
      } else {
        setState(() {
          if (_videoController!.value.isPlaying) {
            _videoController!.pause();
            _isPlaying = false;
          } else {
            _videoController!.play();
            _isPlaying = true;
          }
        });
      }
    }
  }

  void _handleReaction(String reaction) {
    setState(() {
      if (_selectedReaction == reaction) {
        _selectedReaction = null;
      } else {
        _selectedReaction = reaction;
      }
    });
    context.read<ChatConversationBloc>().add(
          AddReaction(widget.message.id, _selectedReaction ?? ''),
        );
  }

  Widget _buildVideoPlayer() {
    if (_isVideoLoading) {
      return Container(
        width: 240.w,
        height: 180.h,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (_isVideoError) {
      return Container(
        width: 240.w,
        height: 180.h,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 48.w,
            ),
            SizedBox(height: 8.h),
            Text(
              'Failed to load video',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    if (!_isVideoInitialized || _videoController == null) {
      return Container(
        width: 240.w,
        height: 180.h,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_videoController!),
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _isPlaying ? 0.0 : 0.8,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isVideoEnded ? Icons.replay : (_isPlaying ? Icons.pause : Icons.play_arrow),
                      size: 32.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder(
              valueListenable: _videoController!,
              builder: (context, VideoPlayerValue value, child) {
                return Container(
                  height: 4.h,
                  color: Colors.black.withOpacity(0.5),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value.position.inMilliseconds /
                        (value.duration.inMilliseconds == 0
                            ? 1
                            : value.duration.inMilliseconds),
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
                  videoPlayer: widget.message.messageType == 'video' &&
                          widget.message.attachments.isNotEmpty
                      ? _buildVideoPlayer()
                      : null,
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
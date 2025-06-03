import 'package:chat_app_ttcs/common/helper/helper.dart';
import 'package:chat_app_ttcs/common/widgets/base_image.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:chat_app_ttcs/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_conversation_bloc.dart';
import '../bloc/chat_conversation_event.dart';

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
        print('Updated reaction: $_selectedReaction');
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
      print('Error initializing video: $e');
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

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              InteractiveViewer(
                child: Center(
                  child: imageUrl.startsWith('/')
                      ? Image.file(
                          File(imageUrl),
                          fit: BoxFit.contain,
                        )
                      : BaseCacheImage(
                          url: imageUrl,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              Positioned(
                top: 40.h,
                right: 20.w,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFullVideo(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: videoUrl.startsWith('/')
                    ? _buildVideoPlayer(File(videoUrl))
                    : _buildVideoPlayer(videoUrl),
              ),
              Positioned(
                top: 40.h,
                right: 20.w,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer(dynamic source) {
    return FutureBuilder<VideoPlayerController>(
      future: () async {
        final controller = source is String
            ? VideoPlayerController.network(
                source,
                httpHeaders: {
                  'Range': 'bytes=0-',
                  'Accept': '*/*',
                  'Connection': 'keep-alive',
                },
                formatHint: VideoFormat.hls,
              )
            : VideoPlayerController.file(source);

        await controller.initialize().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Video initialization timed out');
          },
        );
        return controller;
      }(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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

        if (snapshot.hasError) {
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
                  'Failed to load video\nTap to retry',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 32.w,
                  ),
                  onPressed: () {
                    setState(() {
                      _isVideoInitialized = false;
                      _isVideoError = false;
                    });
                    _initializeVideo();
                  },
                ),
              ],
            ),
          );
        }

        final controller = snapshot.data!;
        return AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(controller),
              IconButton(
                icon: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 48.w,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    controller.value.isPlaying
                        ? controller.pause()
                        : controller.play();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleReaction(String reaction) {
    print('Handling reaction: $reaction');
    print('Message ID: ${widget.message.id}');
    setState(() {
      _selectedReaction = reaction;
      print('Selected reaction updated: $_selectedReaction');
    });
    print('Adding AddReaction event to bloc');
    context.read<ChatConversationBloc>().add(
          AddReaction(widget.message.id, reaction),
        );
    print('AddReaction event added to bloc');
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
            _buildAvatar(),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: widget.isSender
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onLongPress: () {
                        _showReactionMenu(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: widget.isSender
                              ? AppColors.primaryColor_500
                              : AppColors.neutral_100,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            topRight: Radius.circular(12.r),
                            bottomLeft: Radius.circular(widget.isSender ? 12.r : 0),
                            bottomRight: Radius.circular(widget.isSender ? 0 : 12.r),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.message.messageType == 'video' &&
                                widget.message.attachments.isNotEmpty)
                              GestureDetector(
                                onTap: () => _showFullVideo(
                                  context,
                                  widget.message.attachments.first,
                                ),
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: 240.w,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 240.w,
                                        height: 180.h,
                                        color: Colors.black,
                                        child: _buildVideoThumbnail(
                                          widget.message.attachments.first,
                                        ),
                                      ),
                                      Container(
                                        width: 48.w,
                                        height: 48.h,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.play_arrow,
                                          size: 32.w,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (widget.message.messageType == 'image' &&
                                widget.message.attachments.isNotEmpty)
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: 240.w,
                                ),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        widget.message.attachments.length == 1
                                            ? 1
                                            : 2,
                                    crossAxisSpacing: 4.w,
                                    mainAxisSpacing: 4.h,
                                    childAspectRatio:
                                        widget.message.attachments.length == 1
                                            ? 1.5
                                            : 1,
                                  ),
                                  itemCount: widget.message.attachments.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () => _showFullImage(
                                          context, widget.message.attachments[index]),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8.r),
                                        child: _buildImage(
                                            widget.message.attachments[index]),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            if (widget.message.text.isNotEmpty)
                              RichText(
                                text: TextSpan(
                                  children: _buildTextSpans(
                                    widget.message.text,
                                    widget.isSender ? Colors.white : AppColors.neutral_900,
                                  ),
                                ),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.visible,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (_selectedReaction != null)
                      Positioned(
                        bottom: -8.h,
                        right: widget.isSender ? null : 0,
                        left: widget.isSender ? 0 : null,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _selectedReaction!,
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: _selectedReaction != null ? 16.h : 4.h),
                Text(
                  Helper.formatTime(widget.message.createdAt),
                  style: AppTextStyles.regular_12px.copyWith(
                    color: AppColors.neutral_500,
                  ),
                ),
              ],
            ),
          ),
          if (widget.isSender) ...[
            SizedBox(width: 8.w),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  void _showReactionMenu(BuildContext context) {
    print('Showing reaction menu');
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    print('Tapped outside reaction menu');
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Positioned(
                top: position.top - 50.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _reactions.map((reaction) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              print('Reaction tapped: $reaction');
                              _handleReaction(reaction);
                              print('Closing reaction menu');
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text(
                                reaction,
                                style: TextStyle(fontSize: 16.sp),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(String imageUrl) {
    // Check if the URL is a local file path
    if (imageUrl.startsWith('/')) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading local image: $error');
          return _buildErrorWidget();
        },
      );
    }

    // For network images
    return BaseCacheImage(
      url: imageUrl,
      fit: BoxFit.cover,
      errorWidget: _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: AppColors.neutral_200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 24.w,
            color: AppColors.neutral_500,
          ),
          SizedBox(height: 4.h),
          Text(
            'Failed to load image',
            style: AppTextStyles.regular_12px.copyWith(
              color: AppColors.neutral_500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = widget.message.sender?.avatarUrl;
    print('Avatar URL: $avatarUrl'); // Debug log

    if (avatarUrl == null || avatarUrl.isEmpty) {
      return Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: AppColors.neutral_200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.person,
          size: 20.w,
          color: AppColors.neutral_500,
        ),
      );
    }

    return BaseCacheImage(
      url: avatarUrl,
      width: 32.w,
      height: 32.h,
      borderRadius: BorderRadius.circular(16),
      fit: BoxFit.cover,
      errorWidget: Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: AppColors.neutral_200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.person,
          size: 20.w,
          color: AppColors.neutral_500,
        ),
      ),
    );
  }

  bool _containsEmoji(String text) {
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F000}-\u{1F02F}\u{1F0A0}-\u{1F0FF}\u{1F100}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{1F1E0}-\u{1F1FF}]',
      unicode: true,
    );
    return emojiRegex.hasMatch(text);
  }

  String _getEmojiFontFamily() {
    if (Platform.isWindows) {
      return 'Segoe UI Emoji';
    } else if (Platform.isIOS) {
      return 'Apple Color Emoji';
    } else {
      return 'Noto Color Emoji';
    }
  }

  List<TextSpan> _buildTextSpans(String text, Color textColor) {
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F000}-\u{1F02F}\u{1F0A0}-\u{1F0FF}\u{1F100}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{1F1E0}-\u{1F1FF}]',
      unicode: true,
    );

    final spans = <TextSpan>[];
    String currentText = '';
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (emojiRegex.hasMatch(char)) {
        if (currentText.isNotEmpty) {
          spans.add(TextSpan(
            text: currentText,
            style: AppTextStyles.regular_16px.copyWith(
              color: textColor,
              fontFamily: 'Noto Sans',
            ),
          ));
          currentText = '';
        }
        spans.add(TextSpan(
          text: char,
          style: AppTextStyles.regular_16px.copyWith(
            color: textColor,
            fontFamily: _getEmojiFontFamily(),
          ),
        ));
      } else {
        currentText += char;
      }
    }
    
    if (currentText.isNotEmpty) {
      spans.add(TextSpan(
        text: currentText,
        style: AppTextStyles.regular_16px.copyWith(
          color: textColor,
          fontFamily: 'Noto Sans',
        ),
      ));
    }
    
    return spans;
  }

  Widget _buildVideoThumbnail(String videoUrl) {
    if (videoUrl.startsWith('/')) {
      // For local files, use a placeholder or first frame
      return Container(
        color: Colors.black,
        child: Icon(
          Icons.video_file,
          size: 48.w,
          color: Colors.white,
        ),
      );
    } else {
      // For network videos, use a thumbnail from the video
      return BaseCacheImage(
        url: videoUrl,
        fit: BoxFit.cover,
        errorWidget: Container(
          color: Colors.black,
          child: Icon(
            Icons.video_file,
            size: 48.w,
            color: Colors.white,
          ),
        ),
      );
    }
  }
}

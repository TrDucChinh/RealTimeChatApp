import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme/utils/app_colors.dart';
import '../../../models/message_model.dart';
import 'image_grid.dart';
import 'message_text.dart';
import 'reaction_badge.dart';
import 'video_thumb.dart';

class MessageContent extends StatelessWidget {
  final MessageModel message;
  final bool isSender;
  final String? selectedReaction;
  final VoidCallback onLongPress;
  final Widget? videoPlayer;

  const MessageContent({
    super.key,
    required this.message,
    required this.isSender,
    this.selectedReaction,
    required this.onLongPress,
    this.videoPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onLongPress: onLongPress,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              color: isSender
                  ? AppColors.primaryColor_500
                  : AppColors.neutral_100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
                bottomLeft: Radius.circular(isSender ? 12.r : 0),
                bottomRight: Radius.circular(isSender ? 0 : 12.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.messageType == 'video' &&
                    message.attachments.isNotEmpty)
                  videoPlayer ?? VideoThumbnail(
                    videoUrl: message.attachments.first,
                  ),
                if (message.messageType == 'image' &&
                    message.attachments.isNotEmpty)
                  ImageGrid(images: message.attachments),
                if (message.text.isNotEmpty)
                  MessageText(
                    text: message.text,
                    isSender: isSender,
                  ),
              ],
            ),
          ),
        ),
        if (selectedReaction != null)
          ReactionBadge(
            reaction: selectedReaction!,
            isSender: isSender,
          ),
      ],
    );
  }
}
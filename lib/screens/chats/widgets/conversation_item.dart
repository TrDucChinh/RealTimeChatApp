import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:chat_app_ttcs/common/widgets/base_image.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';

import '../../../models/conversation_model.dart';

class ConversationItem extends StatelessWidget {
  final ConversationModel conversation;
  final String currentUserId;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final otherUser = conversation.getOtherUser(currentUserId);
    final lastMessage = conversation.lastMessage;
    final unreadCount = conversation.unreadCount;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BaseCacheImage(
            url: otherUser.avatarUrl,
            width: 42.w,
            height: 42.h,
            borderRadius: BorderRadius.circular(25),
            fit: BoxFit.cover,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUser.username,
                  style: AppTextStyles.bold_16px.copyWith(
                    color: AppColors.neutral_900,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  lastMessage?.text ?? 'No messages yet',
                  style: AppTextStyles.bold_12px.copyWith(
                    color: AppColors.neutral_300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (lastMessage != null)
                Text(
                  _formatTime(lastMessage.createdAt),
                  style: AppTextStyles.bold_12px.copyWith(
                    color: AppColors.neutral_500,
                  ),
                ),
              SizedBox(height: 10.h),
              if (unreadCount.isNotEmpty)
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 20.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue_500,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Center(
                      child: Text(
                        unreadCount.values.first.toString(),
                        style: AppTextStyles.bold_12px.copyWith(
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0 && now.day == time.day) {
      return DateFormat.Hm().format(time); // e.g. 10:25
    } else if (diff.inDays == 1 ||
        (now.day - time.day == 1 &&
            now.month == time.month &&
            now.year == time.year)) {
      return 'Yesterday';
    } else {
      return '${DateFormat.Hm().format(time)}  ${DateFormat('dd/MM').format(time)}';
    }
  }
}

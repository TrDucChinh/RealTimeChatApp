import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:chat_app_ttcs/common/widgets/base_image.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:chat_app_ttcs/common/helper/emoji_helper.dart';

import '../../../common/helper/helper.dart';
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
          if (otherUser.avatarUrl.isNotEmpty && Uri.tryParse(otherUser.avatarUrl)?.hasAbsolutePath == true)
            BaseCacheImage(
              url: otherUser.avatarUrl,
              width: 42.w,
              height: 42.h,
              borderRadius: BorderRadius.circular(25),
              fit: BoxFit.cover,
              errorWidget: Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  color: AppColors.neutral_200,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.person,
                  size: 24.w,
                  color: AppColors.neutral_400,
                ),
              ),
            )
          else
            Container(
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                color: AppColors.neutral_200,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.person,
                size: 24.w,
                color: AppColors.neutral_400,
              ),
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
                RichText(
                  text: TextSpan(
                    children: EmojiHelper.buildTextSpans(
                      lastMessage == null
                          ? (lastMessage?.messageType == 'image'
                              ? 'A media message'
                              : 'No messages yet')
                          : (lastMessage.messageType == 'text'
                              ? lastMessage.text
                              : lastMessage.text.isNotEmpty
                                  ? lastMessage.text
                                  : 'A media message'),
                      AppColors.neutral_300,
                      fontSize: 12.sp,
                    ),
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
                  Helper.formatTime(lastMessage.createdAt),
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
}

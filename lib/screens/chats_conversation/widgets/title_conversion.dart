import 'package:chat_app_ttcs/common/widgets/base_image.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:chat_app_ttcs/models/conversation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/assets/app_icons.dart';

class TitleConversion extends StatelessWidget {
  const TitleConversion({
    super.key,
    required this.conversation,
  });

  final ConversationModel conversation;

  @override
  Widget build(BuildContext context) {
    final otherUser = conversation.getOtherUser('67f61de4128812c84510d102');

    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BaseCacheImage(
            url: otherUser.avatar,
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
                  style: AppTextStyles.semiBold_16px.copyWith(
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _capitalizeFirst(otherUser.status),
                  style: AppTextStyles.regular_12px.copyWith(
                    color: AppColors.neutral_500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          SvgPicture.asset(
            AppIcons.videoCam,
            width: 26.w,
            colorFilter: const ColorFilter.mode(
              AppColors.neutral_900,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 12.w),
          SvgPicture.asset(
            AppIcons.phone,
            width: 26.w,
            colorFilter: const ColorFilter.mode(
              AppColors.neutral_900,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}

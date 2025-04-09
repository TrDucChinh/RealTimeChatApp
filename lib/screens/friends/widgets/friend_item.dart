import 'package:chat_app_ttcs/common/widgets/base_image.dart';
import 'package:chat_app_ttcs/config/assets/app_icons.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../config/theme/utils/app_colors.dart';

class FriendItem extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String avatarUrl;

  const FriendItem({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BaseCacheImage(
            url: avatarUrl,
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
                  userName,
                  style: AppTextStyles.bold_16px.copyWith(
                    color: AppColors.neutral_900,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  userEmail,
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
                SvgPicture.asset(
                  AppIcons.addUser,
                  width: 24.w,
                  height: 24.h,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

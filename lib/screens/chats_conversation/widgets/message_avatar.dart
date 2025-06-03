import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/widgets/base_image.dart';

class MessageAvatar extends StatelessWidget {
  final String? avatarUrl;

  const MessageAvatar({super.key, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
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
      url: avatarUrl!,
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
}
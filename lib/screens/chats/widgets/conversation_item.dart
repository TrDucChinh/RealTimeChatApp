import 'package:chat_app_ttcs/common/widgets/base_image.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme/utils/app_colors.dart';

class ConversationItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String lastMessage;
  final String time;
  final String unReadCount;

  const ConversationItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unReadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        right: 24.h,
        left: 24.h,
      ),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BaseCacheImage(
            url: imageUrl,
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
                  name,
                  style: TextStyles.bold_16px.copyWith(
                    color: AppColors.neutral_900,
                  ),
                  
                ),
                SizedBox(height: 8.h),
                Text(
                  lastMessage,
                  style: TextStyles.bold_12px.copyWith(
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
              Text(
                time,
                style: TextStyles.bold_12px.copyWith(
                  color: AppColors.neutral_500,
                ),
              ),
              SizedBox(height: 10.h),
              unReadCount == '0'
                  ? SizedBox(height: 18.h)
                  : ConstrainedBox(
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
                            unReadCount,
                            style: TextStyles.bold_12px.copyWith(
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

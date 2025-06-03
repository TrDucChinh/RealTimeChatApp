import 'package:chat_app_ttcs/config/assets/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app_ttcs/screens/friends/bloc/add_friend_bloc.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:chat_app_ttcs/common/widgets/base_image.dart';

class FriendItem extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String avatarUrl;
  final bool isFriend;
  final String userId;

  const FriendItem({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.avatarUrl,
    required this.userId,
    this.isFriend = false,
  });

  void _showSendRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Send Friend Request',
          style: AppTextStyles.semiBold_18px,
        ),
        content: Text(
          'Do you want to send a friend request to $userName?',
          style: AppTextStyles.regular_16px,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.medium_16px.copyWith(
                color: AppColors.neutral_500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AddFriendBloc>().add(SendFriendRequest(userId));
            },
            child: Text(
              'Send',
              style: AppTextStyles.medium_16px.copyWith(
                color: AppColors.primaryColor_600,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              GestureDetector(
                onTap: isFriend ? null : () => _showSendRequestDialog(context),
                child: isFriend
                    ? Icon(
                        Icons.close,
                        color: AppColors.error,
                        size: 24.sp,
                      )
                    : SvgPicture.asset(
                      AppIcons.addUser,
                      width: 24.w,
                      height: 24.h,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

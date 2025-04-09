import 'package:chat_app_ttcs/config/assets/app_images.dart';
import 'package:chat_app_ttcs/config/localization/app_localizations.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:chat_app_ttcs/screens/friends/widgets/app_bar_friend.dart';
import 'package:chat_app_ttcs/screens/friends/widgets/friend_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/assets/app_icons.dart';
import '../../../config/theme/utils/app_colors.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController searchController = TextEditingController();
  final List<FriendItem> friendList = [
    FriendItem(
      avatarUrl: 'https://images.unsplash.com/photo-1633332755192-727a05c4013d',
      userName: 'David Wayne',
      userEmail: '1235@gmail.com',
    ),
    FriendItem(
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
      userName: 'Sarah Johnson',
      userEmail: 'sarah@gmail.com',
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarFriend(),
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// Ô nhập tìm kiếm
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 32.h,
              ),
              child: TextField(
                controller: searchController,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)
                      .translate('seach_friend_hint'),
                  hintStyle: AppTextStyles.regular_16px.copyWith(
                    color: AppColors.neutral_200,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.neutral_100),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.neutral_100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.neutral_100),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 18.5.h,
                    horizontal: 18.5.w,
                  ),
                  isDense: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 10.w, right: 10.w),
                    child: SvgPicture.asset(
                      AppIcons.search,
                      height: 24.h,
                      width: 24.w,
                      color: AppColors.neutral_300,
                    ),
                  ),
                ),
                onSubmitted: (value) {
                  searchController.clear();
                },
              ),
            ),

            /// Danh sách bạn bè hoặc ảnh khi danh sách trống
            Expanded(
              child: friendList.isEmpty
                  ? Center(
                      child: Image.asset(
                        AppImages.cardSearch,
                        height: 320.h,
                        width: 320.w,
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      children: [
                        for (var i = 0; i < friendList.length; i++)
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: friendList[i],
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

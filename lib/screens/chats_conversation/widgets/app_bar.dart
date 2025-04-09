import 'package:chat_app_ttcs/config/localization/app_localizations.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../config/assets/app_icons.dart';

class ChatConversationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ChatConversationAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(60.h.toDouble());

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.white,
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => context.pop(), // Điều hướng về trang trước
        child: Container(
          margin: EdgeInsets.only(left: 16.w),
          padding: EdgeInsets.all(8.r),
          height: 42.h,
          width: 42.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.06),
                blurRadius: 12.r,
                offset: Offset(0, 4), // Độ lệch bóng
              ),
            ],
          ),
          child: SvgPicture.asset(
            AppIcons.arrowBack,
            width: 26.w,
            height: 26.h,
            colorFilter: const ColorFilter.mode(
              AppColors.black,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      title: Text(
        AppLocalizations.of(context).translate('message'),
        style: AppTextStyles.semiBold_22px.copyWith(
          color: AppColors.black,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: GestureDetector(
            onTap: () {
              // Handle settings action
            },
            child: Container(
              padding: EdgeInsets.all(8.r),
              height: 42.h,
              width: 42.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.06),
                    blurRadius: 12.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                AppIcons.dotMenu,
                width: 26.w,
                height: 26.h,
                colorFilter: const ColorFilter.mode(
                  AppColors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

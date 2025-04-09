import 'package:chat_app_ttcs/config/assets/app_icons.dart';
import 'package:chat_app_ttcs/config/localization/app_localizations.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class AppBarFriend extends StatelessWidget implements PreferredSizeWidget {
  const AppBarFriend({super.key});

  @override
  Size get preferredSize => Size.fromHeight(60.h.toDouble());

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor_600,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.white.withOpacity(0),
              AppColors.white.withOpacity(0.2),
            ],
            stops: const [0.81, 1.00],
          ),
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(50.r),
          ),
        ),
      ),
      elevation: 0,
      centerTitle: true, // Căn giữa tiêu đề
      title: Text(
        AppLocalizations.of(context).translate('add_friend'),
        style: AppTextStyles.semiBold_22px.copyWith(
          color: AppColors.white,
        ),
      ),
      leading: GestureDetector(
        onTap: () => context.pop(), // Điều hướng về trang trước
        child: Container(
          margin: EdgeInsets.only(left: 16.w),
          padding: EdgeInsets.all(8.r),
          height: 42.h,
          width: 42.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white.withOpacity(0.2),
          ),
          child: SvgPicture.asset(
            AppIcons.arrowBack,
            width: 26.w,
            height: 26.h,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
        // Điều hướng về trang trước
      ),
    );
  }
}

import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class NavItem extends StatelessWidget {
  final int selectedIndex;
  final int currentIndex;
  final String label;
  final String icon;
  final String selectedIcon;
  
  const NavItem({
    super.key,
    required this.selectedIndex,
    required this.currentIndex,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedIndex == currentIndex;
    
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      height: 70.h,
      width: 78.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: isSelected ? AppColors.gradientLightBlue : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            isSelected ? selectedIcon : icon,
            height: 24.h,
            width: 24.w,
            colorFilter: ColorFilter.mode(
              isSelected ? AppColors.white : AppColors.neutral_300,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 9.h),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.neutral_300,
            ),
          ),
        ],
      ),
    );
  }
}

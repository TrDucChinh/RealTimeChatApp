import 'package:chat_app_ttcs/config/assets/app_icons.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/bottom_nav_cubit.dart';
import 'nav_item.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavCubit, int>(
      builder: (context, selectedIndex) {
        return Container(
          height: 100.h,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  context.read<BottomNavCubit>().updateIndex(0);
                  context.goNamed('chats');
                },
                child: NavItem(
                  selectedIndex: selectedIndex,
                  currentIndex: 0,
                  label: 'Chats',
                  icon: AppIcons.chat,
                  selectedIcon: AppIcons.chatFilled,
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.read<BottomNavCubit>().updateIndex(1);
                  context.goNamed('groups');
                },
                child: NavItem(
                  selectedIndex: selectedIndex,
                  currentIndex: 1,
                  label: 'Groups',
                  icon: AppIcons.group,
                  selectedIcon: AppIcons.groupFilled,
                ),
              ),

              GestureDetector(
                onTap: () {
                  context.read<BottomNavCubit>().updateIndex(2);
                  context.goNamed('profile');
                },
                child: NavItem(
                  selectedIndex: selectedIndex,
                  currentIndex: 2,
                  label: 'Profile',
                  icon: AppIcons.profile,
                  selectedIcon: AppIcons.profileFilled,
                ),
              ),

              GestureDetector(
                onTap: () {
                  context.read<BottomNavCubit>().updateIndex(3);
                  context.goNamed('menu');
                },
                child: NavItem(
                  selectedIndex: selectedIndex,
                  currentIndex: 3,
                  label: 'Menu',
                  icon: AppIcons.menu,
                  selectedIcon: AppIcons.menu,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


import 'package:chat_app_ttcs/config/assets/app_icons.dart';
import 'package:chat_app_ttcs/config/assets/app_images.dart';
import 'package:chat_app_ttcs/config/localization/app_localizations.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String token;
  const ChatAppBar({super.key, required this.token});

  @override
  Size get preferredSize => Size.fromHeight(60.h.toDouble());

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  final ValueNotifier<bool> _isSearching = ValueNotifier<bool>(false);
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _isSearching.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isSearching,
      builder: (context, isSearching, child) {
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
          title: isSearching
              ? Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: AppTextStyles.regular_16px.copyWith(
                      color: AppColors.neutral_900,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate('search'),
                      hintStyle: AppTextStyles.regular_16px.copyWith(
                        color: AppColors.neutral_900,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                    ),
                  ),
                )
              : Row(
                  children: [
                    Image.asset(
                      AppImages.logo,
                      height: 32.h,
                      width: 32.w,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      AppLocalizations.of(context).translate('e_chat'),
                      style: AppTextStyles.semiBold_22px.copyWith(
                        color: AppColors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
          actions: [
            if (!isSearching) ...[
              Padding(
                padding: EdgeInsets.only(right: 25.w),
                child: PopupMenuButton<String>(
                  color: AppColors.white,
                  offset: Offset(0, kToolbarHeight - 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  icon: SvgPicture.asset(
                    AppIcons.add,
                    height: 24.h,
                    width: 24.w,
                  ),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'add_friend',
                      child: _buildPopupMenuItem(
                        context,
                        icon: AppIcons.user,
                        title: AppLocalizations.of(context).translate('add_friend'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'create_group',
                      child: _buildPopupMenuItem(
                        context,
                        icon: AppIcons.group,
                        title: AppLocalizations.of(context).translate('create_group'),
                      ),
                    ),
                  ],
                  onSelected: (String value) {
                    if (value == 'add_friend') {
                      context.pushNamed('addFriend', extra: widget.token);
                    } else if (value == 'create_group') {
                      context.pushNamed('createGroup', extra: widget.token);
                    }
                  },
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.only(right: 24.w),
              child: GestureDetector(
                onTap: () {
                  _isSearching.value = !_isSearching.value;
                  if (!_isSearching.value) {
                    _searchController.clear();
                  }
                },
                child: isSearching
                    ? Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white.withOpacity(0.2),
                        ),
                        child: Icon(
                          Icons.close,
                          color: AppColors.white,
                          size: 24.sp,
                        ),
                      )
                    : SvgPicture.asset(
                        AppIcons.search,
                        height: 24.h,
                        width: 24.w,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPopupMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          height: 24.h,
          width: 24.w,
          colorFilter: const ColorFilter.mode(
            AppColors.neutral_900,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: AppTextStyles.medium_18px.copyWith(
            color: AppColors.neutral_900,
          ),
        ),
      ],
    );
  }
}

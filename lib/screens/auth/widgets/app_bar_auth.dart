import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/localization/app_localizations.dart';
import '../../../config/theme/utils/text_styles.dart';

class AppBarAuth extends StatelessWidget implements PreferredSizeWidget {
  const AppBarAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        AppLocalizations.of(context).translate('reset_password'),
        style: AppTextStyles.bold_20px.copyWith(
          color: AppColors.black,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.white,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(62.h.toDouble());
}

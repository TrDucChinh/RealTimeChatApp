import 'package:chat_app_ttcs/config/assets/app_images.dart';
import 'package:chat_app_ttcs/config/localization/app_localizations.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:chat_app_ttcs/screens/auth/widgets/app_bar_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ConfirmReset extends StatelessWidget {
  final String email;
  const ConfirmReset({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarAuth(),
      backgroundColor: Colors.white,
      body: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                AppImages.emailLock,
                alignment: Alignment.center,
                fit: BoxFit.cover,
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: AppLocalizations.of(context)
                    .translate('confirm_description')
                    .split('{email}')[0],
                style: AppTextStyles.regular_16px.copyWith(
                  color: Color(0xFF7F7E7E),
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: email,
                    style: AppTextStyles.semiBold_16px.copyWith(
                      color: Color(0xFF7F7E7E),
                    ),
                  ),
                  TextSpan(
                    text: AppLocalizations.of(context)
                        .translate('confirm_description')
                        .split('{email}')[1],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16.h,
            ),
            InkWell(
              onTap: () {
                context.pop();
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 17.h,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF03A9F4),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  textAlign: TextAlign.center,
                  AppLocalizations.of(context).translate('back_login'),
                  style: AppTextStyles.semiBold_16px.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:chat_app_ttcs/common/widgets/custom_textformfield.dart';
import 'package:chat_app_ttcs/config/localization/app_localizations.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:chat_app_ttcs/screens/auth/widgets/app_bar_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../common/utils/validate.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    void _send(){
      if (_formKey.currentState!.validate()) {
        context.replaceNamed('confirm', extra: _emailController.text);
      }
    }
    return Scaffold(
      appBar: AppBarAuth(),
      backgroundColor: AppColors.white,
      body: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 29.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24.h,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context).translate('reset_password_title'),
                style: AppTextStyles.regular_16px.copyWith(
                  color: Color(0xFF8E8E93),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 16.h,
            ),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('email'),
                    style: AppTextStyles.regular_16px.copyWith(
                      color: Color(0xFF121A2C),
                    ),
                  ),
                  CustomTextFormField(
                    hintText: 'abc@gmail.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)
                            .translate('email_required');
                      } else if (!Validate.isEmail(value)) {
                        return AppLocalizations.of(context)
                            .translate('invalid_email');
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  InkWell(
                    onTap: () {
                      _send();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 17.h,
                        horizontal: 146.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF03A9F4),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        AppLocalizations.of(context).translate('send'),
                        style: AppTextStyles.semiBold_16px.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
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

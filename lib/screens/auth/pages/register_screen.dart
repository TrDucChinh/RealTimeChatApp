import 'package:chat_app_ttcs/common/widgets/custom_textformfield.dart';
import 'package:chat_app_ttcs/config/assets/app_images.dart';
import 'package:chat_app_ttcs/config/localization/app_localizations.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../common/utils/validate.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.pushNamed(
        'userInfo',
        extra: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Image.asset(
            AppImages.rectangle,
            fit: BoxFit.fill,
            width: double.infinity,
          ),
          SafeArea(
            minimum: EdgeInsets.only(
              left: 24.w,
              right: 24.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('register'),
                      style: AppTextStyles.bold_35px.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.goNamed('login');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue_50,
                          borderRadius: BorderRadius.circular(28.r),
                        ),
                        child: Text(
                          AppLocalizations.of(context).translate('login'),
                          style: AppTextStyles.semiBold_18px.copyWith(
                            color: AppColors.primaryColor_500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 45.h,
                ),
                Text(
                  AppLocalizations.of(context).translate('register_title'),
                  style: AppTextStyles.medium_32px.copyWith(
                    color: AppColors.white,
                  ),
                ),
                SizedBox(
                  height: 200.h,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Email
                          Text(
                            AppLocalizations.of(context).translate('email'),
                            style: AppTextStyles.medium_12px.copyWith(
                              color: AppColors.neutral_600,
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
                          //Password
                          Text(
                            AppLocalizations.of(context).translate('password'),
                            style: AppTextStyles.medium_12px.copyWith(
                              color: AppColors.neutral_600,
                            ),
                          ),
                          CustomTextFormField(
                            hintText: '********',
                            controller: _passwordController,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)
                                    .translate('password_required');
                              } else if (value.length < 6) {
                                return AppLocalizations.of(context)
                                    .translate('password_too_short');
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 24.h,
                          ),
                          InkWell(
                            onTap: _register,
                            child: Container(
                              height: 48.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xFF03A9F4),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('sign_up'),
                                  style: AppTextStyles.hintTextStyle.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

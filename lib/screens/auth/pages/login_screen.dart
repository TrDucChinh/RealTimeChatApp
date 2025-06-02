import 'package:chat_app_ttcs/common/widgets/custom_textformfield.dart';
import 'package:chat_app_ttcs/config/assets/app_images.dart';
import 'package:chat_app_ttcs/config/localization/app_localizations.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../common/utils/validate.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginEvent(
              email: _emailController.text,
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.goNamed('chats', extra: state.token);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
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
                        AppLocalizations.of(context).translate('login'),
                        style: AppTextStyles.bold_35px.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      InkWell(
                        onTap: () {},
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
                            AppLocalizations.of(context).translate('register'),
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
                    AppLocalizations.of(context).translate('login_title'),
                    style: AppTextStyles.medium_32px.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(
                    height: 146.h,
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
                              AppLocalizations.of(context)
                                  .translate('password'),
                              style: AppTextStyles.medium_12px.copyWith(
                                color: AppColors.neutral_600,
                              ),
                            ),
                            CustomTextFormField(
                              hintText: '********',
                              controller: _passwordController,
                              isPassword: true,
                            ),
                            SizedBox(
                              height: 16.h,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () {
                                  context.pushNamed('forgotPassword');
                                },
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('forgot_password'),
                                  style: AppTextStyles.medium_16px.copyWith(
                                    color: Color(0xFF03A9F4),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 24.h,
                            ),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                return InkWell(
                                  onTap: state is AuthLoading ? null : _login,
                                  child: Container(
                                    height:
                                        48.h, // Cố định chiều cao của button
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF03A9F4),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Center(
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: state is AuthLoading
                                            ? SizedBox(
                                                height: 20.h,
                                                width: 20.h,
                                                child:
                                                    const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : Text(
                                                AppLocalizations.of(context)
                                                    .translate('sign_in'),
                                                style: AppTextStyles
                                                    .hintTextStyle
                                                    .copyWith(
                                                  color: AppColors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                );
                              },
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
      ),
    );
  }
}

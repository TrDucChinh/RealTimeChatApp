import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../config/assets/app_images.dart';
import '../../../config/localization/app_localizations.dart';
import '../../../config/theme/utils/text_styles.dart';
import '../../../sample_token.dart';
import '../../../services/network_service.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> params =
        GoRouterState.of(context).extra as Map<String, dynamic>;
    final String email = params['email'] as String;
    final String password = params['password'] as String;

    return BlocProvider(
      create: (context) => RegisterBloc(
        NetworkService(
          baseUrl: baseUrl2,
          token: '',
        ),
      ),
      child: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            context.goNamed('login');
          } else if (state is RegisterError) {
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
                      height: 50.h,
                    ),
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48.r,
                            backgroundColor: AppColors.neutral_200,
                            child: Icon(
                              Icons.person,
                              size: 64.r,
                              color: AppColors.white,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor_500,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              padding: EdgeInsets.all(6.r),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18.r,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 150.h),
                    Row(
                      children: [
                        Icon(
                          size: 32.r,
                          Icons.person,
                          color: AppColors.neutral_600,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Your Name',
                              border: UnderlineInputBorder(),
                              hintStyle: AppTextStyles.regular_22px.copyWith(
                                color: AppColors.neutral_400,
                              ),
                            ),
                            style: AppTextStyles.regular_22px.copyWith(
                              color: AppColors.neutral_900,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        BlocBuilder<RegisterBloc, RegisterState>(
                          builder: (context, state) {
                            final isLoading = state is RegisterLoading;
                            return InkWell(
                              onTap:
                                  _nameController.text.isNotEmpty && !isLoading
                                      ? () {
                                          context.read<RegisterBloc>().add(
                                                SignUpEvent(
                                                  username: _nameController.text,
                                                  email: email,
                                                  password: password,
                                                ),
                                              );
                                        }
                                      : null,
                              child: CircleAvatar(
                                backgroundColor: _nameController.text.isNotEmpty
                                    ? AppColors.lightBlue_500
                                    : AppColors.lightBlue_100,
                                child: isLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        Icons.arrow_forward,
                                        color: AppColors.white,
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

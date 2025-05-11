import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/utils/app_colors.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final FocusNode? focusNode;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.validator,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.focusNode,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isObscure = false;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: widget.isPassword ? _isObscure : false,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      maxLines: 1,
      decoration: InputDecoration(
        fillColor: AppColors.white,
        filled: true,
        hintText: widget.hintText,
        hintStyle: AppTextStyles.hintTextStyle.copyWith(
          color: AppColors.black,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 12.5.h,
          horizontal: 14.w,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.black.withOpacity(0.25),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.black.withOpacity(0.25),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        errorStyle: TextStyle(
          fontSize: 12,
          color: Colors.red,
          height: 1.3, // Điều chỉnh khoảng cách dòng
        ),
        errorMaxLines: 2,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon:
                    Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              )
            : null,
      ),
    );
  }
}
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/widgets/base_image.dart';
import '../../../config/theme/utils/app_colors.dart';
import '../../../config/theme/utils/text_styles.dart';

class ImageWidget extends StatelessWidget {
  final String imageUrl;

  const ImageWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('/')) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }

    return BaseCacheImage(
      url: imageUrl,
      fit: BoxFit.cover,
      errorWidget: _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: AppColors.neutral_200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 24.w,
            color: AppColors.neutral_500,
          ),
          SizedBox(height: 4.h),
          Text(
            'Failed to load image',
            style: AppTextStyles.regular_12px.copyWith(
              color: AppColors.neutral_500,
            ),
          ),
        ],
      ),
    );
  }
}
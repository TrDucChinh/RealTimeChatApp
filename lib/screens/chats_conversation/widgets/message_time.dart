import 'package:flutter/material.dart';

import '../../../common/helper/helper.dart';
import '../../../config/theme/utils/app_colors.dart';
import '../../../config/theme/utils/text_styles.dart';

class MessageTime extends StatelessWidget {
  final DateTime time;

  const MessageTime({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Text(
      Helper.formatTime(time),
      style: AppTextStyles.regular_12px.copyWith(
        color: AppColors.neutral_500,
      ),
    );
  }
}
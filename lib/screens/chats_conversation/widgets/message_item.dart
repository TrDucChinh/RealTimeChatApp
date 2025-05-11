import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme/utils/app_colors.dart';
import '../../../models/message_model.dart';

class MessageItem extends StatelessWidget {
  const MessageItem({
    super.key,
    required this.message,
    required this.isSender,
  });

  final MessageModel message;
  final bool isSender;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 305.w,
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSender ? AppColors.primaryColor_500 : AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
              bottomLeft: Radius.circular(isSender ? 12.r : 4.r),
              bottomRight: Radius.circular(isSender ? 4.r : 12.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.text,
                style: AppTextStyles.regular_16px.copyWith(
                  color: isSender ? AppColors.white : AppColors.neutral_900,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: AppTextStyles.medium_12px.copyWith(
                      color: isSender ? AppColors.white.withOpacity(0.7) : AppColors.neutral_500,
                    ),
                  ),
                  if (isSender) ...[
                    SizedBox(width: 4.w),
                    _buildStatusIcon(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    final status = message.status['status'] as String?;
    IconData icon;
    Color color;

    switch (status) {
      case 'sending':
        icon = Icons.access_time;
        color = AppColors.white.withOpacity(0.7);
        break;
      case 'sent':
        icon = Icons.check;
        color = AppColors.white.withOpacity(0.7);
        break;
      case 'failed':
        icon = Icons.error_outline;
        color = AppColors.red_500;
        break;
      default:
        icon = Icons.check;
        color = AppColors.white.withOpacity(0.7);
    }

    return Icon(
      icon,
      size: 16.sp,
      color: color,
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}';
    }
  }
}

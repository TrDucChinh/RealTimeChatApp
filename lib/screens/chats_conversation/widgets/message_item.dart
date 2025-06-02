import 'package:chat_app_ttcs/common/widgets/base_image.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:chat_app_ttcs/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender) ...[
            _buildAvatar(),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSender ? AppColors.primaryColor_500 : AppColors.neutral_100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                      bottomLeft: Radius.circular(isSender ? 12.r : 0),
                      bottomRight: Radius.circular(isSender ? 0 : 12.r),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.messageType == 'image' && message.attachments.isNotEmpty)
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: 240.w,
                          ),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: message.attachments.length == 1 ? 1 : 2,
                              crossAxisSpacing: 4.w,
                              mainAxisSpacing: 4.h,
                              childAspectRatio: message.attachments.length == 1 ? 1.5 : 1,
                            ),
                            itemCount: message.attachments.length,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: _buildImage(message.attachments[index]),
                              );
                            },
                          ),
                        ),
                      if (message.text.isNotEmpty)
                        Text(
                          message.text,
                          style: AppTextStyles.regular_16px.copyWith(
                            color: isSender ? Colors.white : AppColors.neutral_900,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatTime(message.createdAt),
                  style: AppTextStyles.regular_12px.copyWith(
                    color: AppColors.neutral_500,
                  ),
                ),
              ],
            ),
          ),
          if (isSender) ...[
            SizedBox(width: 8.w),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    // Check if the URL is a local file path
    if (imageUrl.startsWith('/')) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading local image: $error');
          return _buildErrorWidget();
        },
      );
    }

    // For network images
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

  Widget _buildAvatar() {
    final avatarUrl = message.sender?.avatarUrl;
    print('Avatar URL: $avatarUrl'); // Debug log

    if (avatarUrl == null || avatarUrl.isEmpty) {
      return Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: AppColors.neutral_200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.person,
          size: 20.w,
          color: AppColors.neutral_500,
        ),
      );
    }

    return BaseCacheImage(
      url: avatarUrl,
      width: 32.w,
      height: 32.h,
      borderRadius: BorderRadius.circular(16),
      fit: BoxFit.cover,
      errorWidget: Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: AppColors.neutral_200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.person,
          size: 20.w,
          color: AppColors.neutral_500,
        ),
      ),
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

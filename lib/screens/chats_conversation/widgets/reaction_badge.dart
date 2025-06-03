import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReactionBadge extends StatelessWidget {
  final String reaction;
  final bool isSender;

  const ReactionBadge({
    super.key,
    required this.reaction,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -15.h,
      right: isSender ? null : -10.w,
      left: isSender ? -10.w : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 6.w,
          vertical: 2.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          reaction,
          style: TextStyle(fontSize: 12.sp),
        ),
      ),
    );
  }
}



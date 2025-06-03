import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/widgets/base_image.dart';
import 'image_widget.dart';

class ImageGrid extends StatelessWidget {
  final List<String> images;

  const ImageGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 240.w,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: images.length == 1 ? 1 : 2,
          crossAxisSpacing: 4.w,
          mainAxisSpacing: 4.h,
          childAspectRatio: images.length == 1 ? 1.5 : 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showFullImage(context, images[index]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: ImageWidget(imageUrl: images[index]),
            ),
          );
        },
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              InteractiveViewer(
                child: Center(
                  child: imageUrl.startsWith('/')
                      ? Image.file(
                          File(imageUrl),
                          fit: BoxFit.contain,
                        )
                      : BaseCacheImage(
                          url: imageUrl,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              Positioned(
                top: 40.h,
                right: 20.w,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

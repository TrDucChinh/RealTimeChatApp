import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/widgets/base_image.dart';
import 'video_player_widget.dart';

class VideoThumbnail extends StatelessWidget {
  final String videoUrl;

  const VideoThumbnail({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullVideo(context, videoUrl),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 240.w,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 240.w,
              height: 180.h,
              color: Colors.black,
              child: _buildVideoThumbnail(videoUrl),
            ),
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                size: 32.w,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(String videoUrl) {
    if (videoUrl.startsWith('/')) {
      return Container(
        color: Colors.black,
        child: Icon(
          Icons.video_file,
          size: 48.w,
          color: Colors.white,
        ),
      );
    } else {
      return BaseCacheImage(
        url: videoUrl,
        fit: BoxFit.cover,
        errorWidget: Container(
          color: Colors.black,
          child: Icon(
            Icons.video_file,
            size: 48.w,
            color: Colors.white,
          ),
        ),
      );
    }
  }

  void _showFullVideo(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: videoUrl.startsWith('/')
                    ? VideoPlayerWidget(source: File(videoUrl))
                    : VideoPlayerWidget(source: videoUrl),
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
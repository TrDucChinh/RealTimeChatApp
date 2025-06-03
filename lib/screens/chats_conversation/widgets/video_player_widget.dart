import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final dynamic source;

  const VideoPlayerWidget({super.key, required this.source});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late Future<VideoPlayerController> _controllerFuture;

  @override
  void initState() {
    super.initState();
    _controllerFuture = _initializeController();
  }

  Future<VideoPlayerController> _initializeController() async {
    final controller = widget.source is String
        ? VideoPlayerController.network(
            widget.source,
            httpHeaders: {
              'Range': 'bytes=0-',
              'Accept': '*/*',
              'Connection': 'keep-alive',
            },
            formatHint: VideoFormat.hls,
          )
        : VideoPlayerController.file(widget.source);

    await controller.initialize().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw TimeoutException('Video initialization timed out');
      },
    );
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VideoPlayerController>(
      future: _controllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 240.w,
            height: 180.h,
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: 240.w,
            height: 180.h,
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48.w,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Failed to load video',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          );
        }

        final controller = snapshot.data!;
        return AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(controller),
              IconButton(
                icon: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 48.w,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    controller.value.isPlaying
                        ? controller.pause()
                        : controller.play();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BaseCacheImage extends StatelessWidget {
  const BaseCacheImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit,
    this.borderRadius = BorderRadius.zero,
    this.errorWidget,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius borderRadius;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        width: width,
        height: height,
        imageUrl: url,
        fit: fit ?? BoxFit.cover,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: fit ?? BoxFit.cover,
              colorFilter: const ColorFilter.mode(
                Color.fromARGB(0, 1, 1, 1),
                BlendMode.colorBurn,
              ),
            ),
          ),
        ),
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) =>
            errorWidget ?? const Icon(Icons.error_outline),
      ),
    );
  }
}

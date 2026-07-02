import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../state/app_loading.dart';

class CustomCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0.0,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            color: AppColors.surfaceContainerLow,
            child: const Center(
              child: AppLoading(size: 24),
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            color: AppColors.surfaceContainerLow,
            child: const Center(
              child: Icon(
                Icons.broken_image_rounded,
                color: AppColors.outline,
                size: 24,
              ),
            ),
          ),
    );

    if (borderRadius > 0.0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

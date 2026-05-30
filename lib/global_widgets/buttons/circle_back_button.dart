import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/app_constants.dart';

class CircleBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;

  const CircleBackButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingS),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainerLow,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        color: iconColor ?? AppColors.onSurface,
        onPressed: onPressed ?? () => Navigator.maybePop(context),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/app_constants.dart';

class AppSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onClear;
  final Widget? suffixIcon;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final double? iconSize;

  const AppSearchBar({
    super.key,
    this.hintText = 'Tìm kiếm...',
    this.onChanged,
    this.controller,
    this.onClear,
    this.suffixIcon,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.boxShadow,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 56,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainerHigh,
        borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.radiusL),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.onSurfaceVariant.withOpacity(0.6),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: iconSize ?? 24,
          ),
          suffixIcon: suffixIcon ?? (controller?.text.isNotEmpty == true || onClear != null
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                    onChanged?.call('');
                  },
                )
              : null),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}

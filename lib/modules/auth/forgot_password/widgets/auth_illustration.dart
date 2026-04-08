import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';

class AuthIllustration extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? outerCircleColor;

  const AuthIllustration({
    super.key,
    required this.icon,
    this.iconColor,
    this.outerCircleColor,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = iconColor ?? AppColors.primary;
    final outerColor = outerCircleColor ?? AppColors.primary;

    return Center(
      child: SizedBox(
        width: AppConstants.authIllustrationSize,
        height: AppConstants.authIllustrationSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Layer 1: Radial Gradient Outer Circle
            Container(
              width: AppConstants.authIllustrationSize,
              height: AppConstants.authIllustrationSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    outerColor.withOpacity(AppConstants.opacityHigh),
                    outerColor.withOpacity(AppConstants.opacityLow),
                  ],
                ),
              ),
            ),
            // Layer 2: White Inner Circle with Shadow
            Container(
              width: AppConstants.authInnerCircleSize,
              height: AppConstants.authInnerCircleSize,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(AppConstants.shadowOpacity),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            // Layer 3: Central Icon
            Icon(
              icon,
              size: AppConstants.authIllustrationIconSize,
              color: primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

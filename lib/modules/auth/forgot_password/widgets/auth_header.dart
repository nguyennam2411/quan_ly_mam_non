import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import 'auth_illustration.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? descriptionWidget;
  final IconData icon;
  final Color? iconColor;

  const AuthHeader({
    super.key,
    required this.title,
    required this.icon,
    this.description,
    this.descriptionWidget,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Spacing between AppBar and Illustration
        AppConstants.spacingM,

        // Centered Illustration
        AuthIllustration(
          icon: icon,
          iconColor: iconColor,
        ),

        // Spacing before title
        AppConstants.spacingXL,

        // Left-Aligned Title (Editorial Style)
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Spacing small before description
        AppConstants.spacingS,

        // Description or Custom Description Widget
        if (descriptionWidget != null)
          descriptionWidget!
        else if (description != null)
          Text(
            description!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        
        // Final spacing before form
        AppConstants.spacingXL,
      ],
    );
  }
}

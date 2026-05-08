import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/app_constants.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.horizontalPadding,
        AppConstants.paddingL,
        AppConstants.horizontalPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.onBackground,
                ),
          ),
          if (subtitle != null) ...[
            AppConstants.spacingXS,
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
          AppConstants.spacingL,
        ],
      ),
    );
  }
}

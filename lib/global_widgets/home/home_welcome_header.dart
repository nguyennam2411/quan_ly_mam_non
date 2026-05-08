import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_helper.dart';

class HomeWelcomeHeader extends StatelessWidget {
  final String userName;
  final String greeting;

  const HomeWelcomeHeader({
    super.key,
    required this.userName,
    this.greeting = 'Xin chào,',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.0,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          userName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.onSurface,
                fontSize: 25,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              DateHelper.formatFullDate(DateTime.now()),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

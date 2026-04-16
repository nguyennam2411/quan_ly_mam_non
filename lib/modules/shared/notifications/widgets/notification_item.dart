import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_constants.dart';
import 'package:quan_ly_mam_non/data/models/notification_model.dart';
import 'notification_ui_extension.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel item;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingM,
        ),
        color: item.isRead ? Colors.transparent : AppColors.surfaceContainerHigh,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon đại diện
            _buildIcon(),
            const SizedBox(width: AppConstants.paddingM),
            
            // Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: item.isRead ? FontWeight.w500 : FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeago.format(item.createdAt.toLocal(), locale: 'vi'),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: item.backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        item.icon,
        color: item.iconColor,
        size: 24,
      ),
    );
  }
}

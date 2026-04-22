import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/data/models/notification_model.dart';

extension NotificationUIExtension on NotificationModel {
  IconData get icon {
    switch (type) {
      case 'LEAVE_REQUEST':
        return Icons.assignment_outlined;
      case 'LEAVE_RESULT':
        return Icons.check_circle_outline;
      case 'ATTENDANCE':
      case 'ATTENDANCE_UPDATE':
        return Icons.calendar_today_outlined;
      case 'SYSTEM':
        return Icons.info_outline;
      default:
        return Icons.notifications_none;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'LEAVE_REQUEST':
        return AppColors.primary;
      case 'LEAVE_RESULT':
        return AppColors.success;
      case 'ATTENDANCE':
      case 'ATTENDANCE_UPDATE':
        return AppColors.tertiary;
      case 'SYSTEM':
        return AppColors.secondary;
      default:
        return AppColors.outline;
    }
  }

  Color get backgroundColor {
    switch (type) {
      case 'LEAVE_REQUEST':
        return AppColors.primaryContainer.withOpacity(0.2);
      case 'LEAVE_RESULT':
        return AppColors.successContainer.withOpacity(0.2);
      case 'ATTENDANCE':
      case 'ATTENDANCE_UPDATE':
        return AppColors.tertiaryContainer.withOpacity(0.2);
      case 'SYSTEM':
        return AppColors.secondaryContainer.withOpacity(0.2);
      default:
        return AppColors.surfaceContainer;
    }
  }
}

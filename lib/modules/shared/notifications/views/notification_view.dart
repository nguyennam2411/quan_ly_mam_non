import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_strings.dart';
import 'package:quan_ly_mam_non/global_widgets/state/app_empty_state.dart';
import '../controllers/notification_controller.dart';
import '../widgets/notification_item.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.notificationTitle,
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Nút Đánh dấu đã đọc tất cả
          Obx(() => controller.unreadCount > 0 
            ? IconButton(
                icon: const Icon(Icons.done_all, color: AppColors.primary),
                tooltip: AppStrings.notificationMarkAllRead,
                onPressed: () => controller.markAllAsRead(),
              )
            : const SizedBox.shrink()
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchNotifications,
        color: AppColors.primary,
        child: Obx(() {
          if (controller.isLoading.value && controller.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.notifications.isEmpty) {
            return AppEmptyState(
              title: AppStrings.notificationEmpty,
              icon: Icons.notifications_off_outlined,
              onRetry: controller.fetchNotifications,
            );
          }

          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: controller.notifications.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: AppColors.surfaceVariant.withOpacity(0.5),
            ),
            itemBuilder: (context, index) {
              final item = controller.notifications[index];
              return NotificationItem(
                item: item,
                onTap: () => controller.onNotificationTap(item),
              );
            },
          );
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_constants.dart';
import 'package:quan_ly_mam_non/routes/app_routes.dart';
import 'package:quan_ly_mam_non/data/models/activity_log_model.dart';
import 'package:quan_ly_mam_non/global_widgets/headers/main_app_bar.dart';
import 'package:quan_ly_mam_non/global_widgets/state/app_empty_state.dart';
import 'package:quan_ly_mam_non/global_widgets/state/app_loading.dart';
import 'package:quan_ly_mam_non/global_widgets/images/custom_cached_image.dart';
import '../controllers/teacher_activity_log_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class TeacherActivityLogView extends GetView<TeacherActivityLogController> {
  const TeacherActivityLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(
        title: 'Nhật ký hoạt động',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoading();
        }

        if (controller.logs.isEmpty) {
          return AppEmptyState(
            title: 'Chưa có hoạt động nào',
            description: 'Các hoạt động của lớp học sẽ được giáo viên đăng tại đây.',
            icon: Icons.history_edu_rounded,
            onRetry: controller.fetchLogs,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchLogs,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            itemCount: controller.logs.length,
            itemBuilder: (context, index) {
              final log = controller.logs[index];
              return _buildActivityCard(context, log);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.bottomSheet(
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusL),
                  topRight: Radius.circular(AppConstants.radiusL),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.groups_rounded, color: AppColors.primary),
                      title: const Text(
                        'Đăng hoạt động chung',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Đăng một ghi chú & ảnh chung cho cả lớp hoặc một nhóm'),
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.TEACHER_ADD_ACTIVITY_LOG);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                      title: const Text(
                        'Phân bổ ảnh riêng lẻ (Đăng nhanh)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Chọn nhiều ảnh từ máy, gán riêng từng bé để phụ huynh xem'),
                      onTap: () {
                        Get.back();
                        controller.resetAllocatorForm();
                        Get.toNamed(Routes.TEACHER_PHOTO_ALLOCATOR);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
          );
        },
        label: const Text('Đăng hoạt động'),
        icon: const Icon(Icons.add_photo_alternate_rounded),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityLogModel log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Student target
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(
                    log.studentId == null ? Icons.groups_rounded : Icons.person_rounded,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.studentId == null ? 'Cả lớp' : (log.student?.name ?? 'Học sinh'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        timeago.format((log.createdAt ?? DateTime.now()).toLocal(), locale: 'vi'),
                        style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          if (log.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
              child: Text(log.content),
            ),

          const SizedBox(height: 12),

          // Images
          if (log.images != null && log.images!.isNotEmpty)
            _buildImageGrid(log.images!),

          const SizedBox(height: 12),

          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => controller.toggleLike(log),
                  icon: Icon(
                    log.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 20,
                    color: log.isLiked ? Colors.red : null,
                  ),
                  label: Text('${log.likeCount > 0 ? log.likeCount : ''} Yêu thích'),
                ),
                TextButton.icon(
                  onPressed: () => controller.showComments(log),
                  icon: const Icon(Icons.mode_comment_outlined, size: 20),
                  label: Text('${log.commentCount > 0 ? log.commentCount : ''} Bình luận'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<dynamic> images) {
    if (images.length == 1) {
      return ClipRRect(
        child: CustomCachedImage(
          imageUrl: images[0].imageUrl,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: CustomCachedImage(
                imageUrl: images[index].imageUrl,
                width: 150,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}

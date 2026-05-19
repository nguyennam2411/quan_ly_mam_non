import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_constants.dart';
import 'package:quan_ly_mam_non/routes/app_routes.dart';
import 'package:quan_ly_mam_non/data/models/activity_log_model.dart';
import '../controllers/teacher_activity_log_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class TeacherActivityLogView extends GetView<TeacherActivityLogController> {
  const TeacherActivityLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nhật ký hoạt động'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_edu_rounded, size: 64, color: AppColors.outlineVariant),
                const SizedBox(height: 16),
                Text(
                  'Chưa có hoạt động nào được đăng',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
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
        onPressed: () => Get.toNamed(Routes.TEACHER_ADD_ACTIVITY_LOG),
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
          if (log.content != null && log.content!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
              child: Text(log.content!),
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
        child: Image.network(
          images[0].imageUrl,
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
              child: Image.network(
                images[index].imageUrl,
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

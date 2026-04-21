import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_constants.dart';
import 'package:quan_ly_mam_non/data/models/activity_log_model.dart';
import '../controllers/parent_activity_log_controller.dart';
import 'widgets/comment_bottom_sheet.dart';
import 'package:timeago/timeago.dart' as timeago;

class ParentActivityLogView extends GetView<ParentActivityLogController> {
  const ParentActivityLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nhật ký của bé'),
        centerTitle: true,
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
                Icon(Icons.auto_awesome_motion_rounded, size: 64, color: AppColors.outlineVariant),
                const SizedBox(height: 16),
                Text(
                  'Bé chưa có hoạt động nào hôm nay',
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
    );
  }

  Widget _buildActivityCard(BuildContext context, dynamic log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.secondaryContainer,
              child: Icon(
                log.studentId == null ? Icons.school_rounded : Icons.face_rounded,
                color: AppColors.onSecondaryContainer,
              ),
            ),
            title: Text(
              log.studentId == null ? 'Hoạt động cả lớp' : 'Hoạt động cá nhân',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              timeago.format(log.createdAt ?? DateTime.now(), locale: 'vi'),
              style: const TextStyle(fontSize: 12),
            ),
          ),

          // Content
          if (log.content != null && log.content!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                log.content!,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),

          // Images
          if (log.images != null && log.images!.isNotEmpty)
            _buildImageDisplay(log.images!),

          const SizedBox(height: 16),
          
          // Interaction (Optional: Like/Comment placeholder)
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
                  onPressed: () => _showCommentBottomSheet(context, log),
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

  void _showCommentBottomSheet(BuildContext context, ActivityLogModel log) {
    Get.bottomSheet(
      CommentBottomSheet(log: log),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildImageDisplay(List<dynamic> images) {
    if (images.length == 1) {
      return ClipRRect(
        child: Image.network(
          images[0].imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: AppColors.surfaceContainerLow,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: Image.network(
                images[index].imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}

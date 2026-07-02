import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_constants.dart';
import 'package:quan_ly_mam_non/data/models/activity_image_model.dart';
import 'package:quan_ly_mam_non/data/models/activity_log_model.dart';
import '../controllers/parent_activity_log_controller.dart';
import 'package:quan_ly_mam_non/global_widgets/headers/main_app_bar.dart';
import 'package:quan_ly_mam_non/global_widgets/state/app_empty_state.dart';
import 'package:quan_ly_mam_non/global_widgets/state/app_loading.dart';
import 'package:quan_ly_mam_non/global_widgets/dialogs/comment_bottom_sheet.dart';
import 'package:quan_ly_mam_non/global_widgets/images/custom_cached_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class ParentActivityLogView extends GetView<ParentActivityLogController> {
  const ParentActivityLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(
        title: 'Nhật ký của bé',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoading();
        }

        if (controller.logs.isEmpty) {
          return AppEmptyState(
            title: 'Chưa có hoạt động nào',
            description: 'Các hoạt động trong ngày của bé sẽ được cập nhật tại đây.',
            icon: Icons.auto_awesome_motion_rounded,
            onRetry: controller.fetchLogs,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchLogs,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            itemCount: controller.logs.length,
            itemBuilder: (context, index) {
              final log = controller.logs[index];
              return _buildLogCard(context, log);
            },
          ),
        );
      }),
    );
  }

  Widget _buildLogCard(BuildContext context, ActivityLogModel log) {
    // Tên giáo viên: lấy từ student model nếu không có thì dùng teacherId rút ngắn
    final displayName = log.student?.name ?? 'Giáo viên';
    final avatarLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'G';

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    avatarLetter,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        log.createdAt != null
                            ? timeago.format(log.createdAt!, locale: 'vi')
                            : '',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Text
          if (log.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppConstants.paddingM, 0, AppConstants.paddingM, AppConstants.paddingM),
              child: Text(log.content, style: const TextStyle(fontSize: 15, height: 1.4)),
            ),

          // Images
          if (log.images != null && log.images!.isNotEmpty)
            _buildImageDisplay(log.images!),

          const Divider(height: 1),

          // Actions (Like & Comment)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Obx(() {
                  // Rebuild khi logs thay đổi để phản ánh trạng thái like mới nhất
                  final currentLog = controller.logs.firstWhereOrNull((l) => l.id == log.id) ?? log;
                  return TextButton.icon(
                    onPressed: () => controller.toggleLike(currentLog),
                    icon: Icon(
                      currentLog.isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                      color: currentLog.isLiked ? Colors.red : Colors.grey,
                    ),
                    label: Text(
                      currentLog.isLiked ? 'Đã thích' : 'Thích',
                      style: TextStyle(color: currentLog.isLiked ? Colors.red : Colors.grey[700]),
                    ),
                  );
                }),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CommentBottomSheet(
                        activityLog: log,
                        onSend: (content) => controller.addComment(log, content),
                        getComments: () => controller.getComments(log.id!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.mode_comment_outlined, color: Colors.grey),
                  label: Text('Bình luận', style: TextStyle(color: Colors.grey[700])),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay(List<ActivityImageModel> images) {
    if (images.length == 1) {
      return CustomCachedImage(
        imageUrl: images[0].imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CustomCachedImage(
              imageUrl: images[index].imageUrl,
              fit: BoxFit.cover,
              borderRadius: AppConstants.radiusM,
            ),
          );
        },
      ),
    );
  }
}

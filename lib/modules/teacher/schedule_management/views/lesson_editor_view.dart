import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_database.dart';
import 'package:quan_ly_mam_non/core/values/app_constants.dart';
import 'package:quan_ly_mam_non/core/utils/dialog.dart';
import 'package:quan_ly_mam_non/global_widgets/images/image_picker_grid.dart';
import 'package:quan_ly_mam_non/global_widgets/buttons/primary_button.dart';
import 'package:quan_ly_mam_non/modules/teacher/schedule_management/controllers/lesson_editor_controller.dart';
import 'package:quan_ly_mam_non/data/models/schedule_model.dart';


class LessonEditorView extends GetView<LessonEditorController> {
  const LessonEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime date = Get.arguments['date'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Soạn bài học', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          Obx(() => controller.isSaving.value
              ? const SizedBox(
                  width: 56,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : TextButton(
                  onPressed: () async {
                    final confirm = await AppDialogs.showConfirm(
                      title: 'Xác nhận lưu',
                      message: 'Bạn có chắc chắn muốn lưu nội dung bài học này không?',
                    );
                    if (confirm) {
                      controller.saveLesson(date);
                    }
                  },
                  child: const Text('LƯU', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thẻ ngữ cảnh: Ngày và Khung giờ đang soạn
            _buildContextCard(date),
            const SizedBox(height: AppConstants.paddingL),

            // 1. Ô nhập liệu bài học
            _buildInputField(
              controller: controller.titleController,
              label: 'Tiêu đề bài học',
              hint: 'Ví dụ: Làm quen với chữ cái A, B, C',
              icon: Icons.title_rounded,
            ),
            const SizedBox(height: AppConstants.paddingM),
            
            _buildInputField(
              controller: controller.objectivesController,
              label: 'Mục tiêu bài học',
              hint: 'Trẻ nhận biết và phát âm đúng...',
              icon: Icons.track_changes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: AppConstants.paddingM),
            
            _buildInputField(
              controller: controller.contentController,
              label: 'Nội dung chi tiết',
              hint: 'Các bước thực hiện bài dạy...',
              icon: Icons.description_outlined,
              maxLines: 5,
            ),
            
            const SizedBox(height: AppConstants.paddingL),
            
            // 2. Tài liệu
            _buildInputField(
              controller: controller.youtubeController,
              label: 'Link Video Youtube (Hướng dẫn)',
              hint: 'Dán đường dẫn video tại đây...',
              icon: Icons.play_circle_filled_rounded,
              iconColor: Colors.red,
            ),
            const SizedBox(height: AppConstants.paddingM),
            
            // Hình ảnh minh họa
            _buildSectionLabel('Hình ảnh minh họa'),
            const SizedBox(height: AppConstants.paddingS),
            Obx(() => ImagePickerGrid(
              images: controller.selectedImages.toList(),
              onImageAdded: controller.addImage,
              onImageRemoved: controller.removeImage,
            )),
            
            const SizedBox(height: AppConstants.paddingL),
            
            // Trạng thái công khai
            _buildSectionLabel('Cài đặt hiển thị'),
            const SizedBox(height: AppConstants.paddingS),
            _buildStatusToggle(),
            
            const SizedBox(height: AppConstants.paddingXXL),

            // Nút Lưu dưới cùng
            Obx(() => PrimaryButton(
              text: 'Lưu bài học',
              isLoading: controller.isSaving.value,
              onPressed: () async {
                final confirm = await AppDialogs.showConfirm(
                  title: 'Xác nhận lưu',
                  message: 'Bạn có chắc chắn muốn lưu nội dung bài học này không?',
                );
                if (confirm) {
                  controller.saveLesson(date);
                }
              },
            )),
            
            const SizedBox(height: AppConstants.paddingL),
          ],
        ),
      ),
    );
  }

  Widget _buildContextCard(DateTime date) {
    return Obx(() {
      final schedule = controller.selectedSchedule.value;
      final dayName = DateFormat('EEEE', 'vi_VN').format(date);
      final fullDate = DateFormat('dd/MM/yyyy').format(date);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$dayName, $fullDate',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule != null 
                      ? 'Khung giờ: ${schedule.startTime} - ${schedule.activityName}'
                      : 'Bài giảng bổ sung (Tự do)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    Color? iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(label),
        const SizedBox(height: AppConstants.paddingS),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.5), fontWeight: FontWeight.normal),
            prefixIcon: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.all(AppConstants.paddingM),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM, vertical: AppConstants.paddingS),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.public_rounded, color: AppColors.secondary, size: 20),
          const SizedBox(width: AppConstants.paddingM),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Công khai bài học',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Phụ huynh sẽ thấy bài học này',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Obx(() => Switch.adaptive(
            value: controller.status.value == AppDatabase.statusPublished,
            onChanged: (val) {
              controller.status.value = val 
                  ? AppDatabase.statusPublished 
                  : AppDatabase.statusDraft;
            },
            activeColor: AppColors.secondary,
          )),
        ],
      ),
    );
  }
}

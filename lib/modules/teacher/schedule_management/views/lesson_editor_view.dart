import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_database.dart';
import 'package:quan_ly_mam_non/core/values/app_constants.dart';
import 'package:quan_ly_mam_non/core/utils/dialog.dart';
import 'package:quan_ly_mam_non/global_widgets/headers/main_app_bar.dart';
import 'package:quan_ly_mam_non/global_widgets/images/image_picker_grid.dart';
import 'package:quan_ly_mam_non/global_widgets/buttons/primary_button.dart';
import 'package:quan_ly_mam_non/modules/teacher/schedule_management/controllers/lesson_editor_controller.dart';
import 'package:quan_ly_mam_non/global_widgets/dialogs/app_loading.dart';
import 'package:quan_ly_mam_non/core/utils/validators.dart';
import 'package:quan_ly_mam_non/core/values/app_strings.dart';

class LessonEditorView extends GetView<LessonEditorController> {
  const LessonEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime date = Get.arguments['date'];

    return Obx(() => PopScope(
      canPop: !controller.hasChanges.value,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await AppDialogs.showExitConfirm();
        if (shouldPop) {
          controller.hasChanges.value = false;
          Get.back(result: result);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: MainAppBar(
        title: AppStrings.lessonEditorTitle,
        actions: [
          Obx(() => controller.isSaving.value
              ? const SizedBox(
                  width: 56,
                  child: Center(child: AppLoading(size: 24)),
                )
              : TextButton(
                  onPressed: () async {
                    if (!(controller.formKey.currentState?.validate() ?? false)) {
                      controller.autovalidateMode.value = AutovalidateMode.onUserInteraction;
                      return;
                    }
                    final confirm = await AppDialogs.showConfirm(
                      title: AppStrings.lessonSaveConfirmTitle,
                      message: AppStrings.lessonSaveConfirmMessage,
                    );
                    if (confirm) {
                      controller.saveLesson(date);
                    }
                  },
                  child: const Text(AppStrings.labelSave, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                )),
        ],
      ),
      body: Form(
        key: controller.formKey,
        autovalidateMode: controller.autovalidateMode.value,
        child: SingleChildScrollView(
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
              label: AppStrings.lessonTitleLabel,
              hint: AppStrings.lessonTitleHint,
              icon: Icons.title_rounded,
              validator: AppValidators.titleRequired,
            ),
            const SizedBox(height: AppConstants.paddingM),
            
            _buildInputField(
              controller: controller.objectivesController,
              label: AppStrings.lessonObjectivesLabel,
              hint: AppStrings.lessonObjectivesHint,
              icon: Icons.track_changes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: AppConstants.paddingM),
            
            _buildInputField(
              controller: controller.contentController,
              label: AppStrings.lessonContentLabel,
              hint: AppStrings.lessonContentHint,
              icon: Icons.description_outlined,
              maxLines: 5,
            ),
            
            const SizedBox(height: AppConstants.paddingL),
            
            // 2. Tài liệu
            _buildInputField(
              controller: controller.youtubeController,
              label: AppStrings.lessonYoutubeLabel,
              hint: AppStrings.lessonYoutubeHint,
              icon: Icons.play_circle_filled_rounded,
              iconColor: Colors.red,
              validator: AppValidators.youtubeUrlOptional,
            ),
            const SizedBox(height: AppConstants.paddingM),
            
            // Hình ảnh minh họa
            _buildSectionLabel(AppStrings.lessonImagesLabel),
            const SizedBox(height: AppConstants.paddingS),
            Obx(() => ImagePickerGrid(
              images: controller.selectedImages.toList(),
              onImageAdded: controller.addImage,
              onImageRemoved: controller.removeImage,
            )),
            
            const SizedBox(height: AppConstants.paddingL),
            
            // Trạng thái công khai
            _buildSectionLabel(AppStrings.lessonDisplaySettingsLabel),
            const SizedBox(height: AppConstants.paddingS),
            _buildStatusToggle(),
            
            const SizedBox(height: AppConstants.paddingXXL),

            // Nút Lưu dưới cùng
            Obx(() => PrimaryButton(
              text: AppStrings.lessonSaveButton,
              isLoading: controller.isSaving.value,
              onPressed: () async {
                if (!(controller.formKey.currentState?.validate() ?? false)) {
                  controller.autovalidateMode.value = AutovalidateMode.onUserInteraction;
                  return;
                }
                final confirm = await AppDialogs.showConfirm(
                  title: AppStrings.lessonSaveConfirmTitle,
                  message: AppStrings.lessonSaveConfirmMessage,
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
    ),
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
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
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
                      ? '${AppStrings.lessonTimeSlotPrefix} ${schedule.startTime} - ${schedule.activityName}'
                      : AppStrings.lessonSupplementalLabel,
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
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(label),
        const SizedBox(height: AppConstants.paddingS),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontWeight: FontWeight.normal),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.lessonStatusPublishLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  AppStrings.lessonStatusPublishDesc,
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
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

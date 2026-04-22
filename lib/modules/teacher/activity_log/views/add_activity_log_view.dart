import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_constants.dart';
import '../controllers/teacher_activity_log_controller.dart';

class AddActivityLogView extends GetView<TeacherActivityLogController> {
  const AddActivityLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đăng hoạt động'),
        actions: [
          Obx(() => controller.isUploading.value
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: controller.submitLog,
                  child: const Text('ĐĂNG', style: TextStyle(fontWeight: FontWeight.bold)),
                )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Selection
            _buildSectionTitle('Gửi đến'),
            _buildStudentSelection(),
            
            const SizedBox(height: 24),

            // Quick Tags
            _buildSectionTitle('Nhãn nhanh'),
            _buildQuickTags(),

            const SizedBox(height: 24),

            // Content
            _buildSectionTitle('Nội dung'),
            TextField(
              controller: controller.contentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập nội dung hoạt động...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Images
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Hình ảnh / Video'),
                IconButton(
                  onPressed: controller.pickImages,
                  icon: const Icon(Icons.add_a_photo_rounded, color: AppColors.primary),
                ),
              ],
            ),
            _buildImagePickerPreview(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildStudentSelection() {
    return Column(
      children: [
        Obx(() => CheckboxListTile(
              title: const Text('Cả lớp'),
              value: controller.isAllClass.value,
              onChanged: (val) {
                controller.isAllClass.value = val ?? true;
                if (controller.isAllClass.value) {
                  controller.selectedStudents.clear();
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            )),
        Obx(() => controller.isAllClass.value
            ? const SizedBox.shrink()
            : Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.students.length,
                  itemBuilder: (context, index) {
                    final student = controller.students[index];
                    return Obx(() {
                      final isSelected = controller.selectedStudents.contains(student.id);
                      return GestureDetector(
                        onTap: () => controller.toggleStudent(student.id),
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryContainer : Colors.white,
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null,
                                child: student.avatarUrl == null ? const Icon(Icons.person) : null,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                student.name.split(' ').last,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              )),
        Obx(() => controller.isAllClass.value
            ? const SizedBox.shrink()
            : TextButton(
                onPressed: () => controller.isAllClass.value = true,
                child: const Text('Thay đổi thành Gửi cả lớp'),
              )),
        if (controller.students.isEmpty && !controller.isAllClass.value)
           const Text('Đang tải danh sách học sinh...', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickTags() {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.quickTags.map((tag) {
            final isSelected = controller.selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (_) => controller.toggleTag(tag),
              selectedColor: AppColors.primaryContainer,
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ));
  }

  Widget _buildImagePickerPreview() {
    return Obx(() {
      if (controller.selectedImages.isEmpty) {
        return GestureDetector(
          onTap: controller.pickImages,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_rounded, color: AppColors.outlineVariant, size: 40),
                const SizedBox(height: 8),
                Text('Chọn ảnh hoạt động', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        );
      }

      return SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.selectedImages.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    image: DecorationImage(
                      image: FileImage(controller.selectedImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => controller.removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_constants.dart';
import 'package:quan_ly_mam_non/data/models/student_model.dart';
import 'package:quan_ly_mam_non/global_widgets/headers/main_app_bar.dart';
import 'package:quan_ly_mam_non/global_widgets/buttons/primary_button.dart';
import 'package:quan_ly_mam_non/global_widgets/inputs/app_search_bar.dart';
import 'package:quan_ly_mam_non/global_widgets/state/app_loading.dart';
import '../controllers/teacher_activity_log_controller.dart';

class PhotoAllocatorView extends GetView<TeacherActivityLogController> {
  const PhotoAllocatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(
        title: 'Phân bổ ảnh học sinh',
        actions: [
          Obx(() => controller.isUploading.value
              ? const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: AppLoading(size: 20),
                )
              : TextButton(
                  onPressed: controller.submitAllocations,
                  child: const Text('ĐĂNG', style: TextStyle(fontWeight: FontWeight.bold)),
                )),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Obx(() {
          if (controller.allocations.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // General comment
                      _buildSectionTitle('Ghi chú chung cho tất cả các ảnh'),
                      TextField(
                        controller: controller.generalNoteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Nhập ghi chú chung (ví dụ: Bé hoạt động vui vẻ hôm nay...)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            borderSide: BorderSide(color: AppColors.outlineVariant),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Photos Title & Add button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('Danh sách ảnh (${controller.allocations.length})'),
                          TextButton.icon(
                            onPressed: controller.pickAllocatorImages,
                            icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                            label: const Text('Thêm ảnh'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Allocation Cards
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.allocations.length,
                        itemBuilder: (context, index) {
                          final alloc = controller.allocations[index];
                          return _buildAllocationCard(context, index, alloc);
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Bottom Button Bar
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Obx(() => PrimaryButton(
                        text: 'HOÀN THÀNH (ĐĂNG ${controller.allocations.length} HOẠT ĐỘNG)',
                        isLoading: controller.isUploading.value,
                        onPressed: controller.submitAllocations,
                      )),
                ),
              ),
            ],
          );
        }),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 80, color: AppColors.outlineVariant),
            const SizedBox(height: 16),
            const Text(
              'Chưa chọn ảnh hoạt động',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Chọn cùng lúc nhiều bức ảnh từ thư viện để phân bổ hoạt động riêng cho từng bé nhanh chóng.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.pickAllocatorImages,
              icon: const Icon(Icons.photo_library_rounded),
              label: const Text('Chọn ảnh từ Thư viện'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationCard(BuildContext context, int index, ImageAllocation alloc) {
    // Find assigned student
    StudentModel? student;
    if (alloc.studentId != null) {
      student = controller.students.firstWhereOrNull((s) => s.id == alloc.studentId);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    child: Image.file(
                      alloc.file,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Assignment & Comment info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Assign student button
                        const Text(
                          'Học sinh gán:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _showStudentPickerDialog(context, index, alloc.studentId),
                          child: student == null
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                                    border: Border.all(color: AppColors.outlineVariant),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                                      SizedBox(width: 4),
                                      Text(
                                        'Gán cho bé',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundImage: student.avatarUrl != null
                                            ? NetworkImage(student.avatarUrl!)
                                            : null,
                                        child: student.avatarUrl == null
                                            ? const Icon(Icons.person, size: 10)
                                            : null,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        student.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onPrimaryContainer,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () => controller.assignStudentToPhoto(index, null),
                                        child: const Icon(
                                          Icons.cancel_rounded,
                                          size: 14,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),

                        // Custom comment
                        const Text(
                          'Ghi chú riêng (không bắt buộc):',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: alloc.noteController,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Sử dụng ghi chú chung...',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Remove button
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: Colors.red[400], size: 20),
                onPressed: () => controller.removeAllocation(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentPickerDialog(BuildContext context, int index, String? currentStudentId) {
    final searchController = TextEditingController();
    final filterQuery = ''.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusL)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxHeight: 500, maxWidth: 350),
          child: Column(
            children: [
              const Text(
                'Chọn học sinh gán ảnh',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),

              // Search field
              AppSearchBar(
                hintText: 'Tìm tên bé...',
                controller: searchController,
                onChanged: (val) => filterQuery.value = val,
                height: 46,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                boxShadow: const [],
                iconSize: 22,
              ),
              const SizedBox(height: 16),

              // Student Grid
              Expanded(
                child: Obx(() {
                  // Filter students matching search query
                  final filteredList = controller.students.where((s) {
                    return s.name.toLowerCase().contains(filterQuery.value.toLowerCase());
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Text(
                        'Không tìm thấy học sinh phù hợp',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.onSurfaceVariant),
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, idx) {
                      final student = filteredList[idx];
                      final isCurrent = student.id == currentStudentId;

                      return GestureDetector(
                        onTap: () {
                          controller.assignStudentToPhoto(index, student.id);
                          Get.back();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrent ? AppColors.primaryContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            border: Border.all(
                              color: isCurrent ? AppColors.primary : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: student.avatarUrl != null
                                    ? NetworkImage(student.avatarUrl!)
                                    : null,
                                child: student.avatarUrl == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                student.name.split(' ').last,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Hủy'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/state/app_loading.dart';
import '../../../../global_widgets/inputs/app_search_bar.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/teacher_classroom_controller.dart';

class TeacherClassroomView extends GetView<TeacherClassroomController> {
  const TeacherClassroomView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => MainAppBar(
              title: controller.classroomName.isNotEmpty
                  ? 'Lớp ${controller.classroomName}'
                  : 'Danh sách lớp',
            )),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Thanh tìm kiếm học sinh
            _buildSearchBox(),
            
            // 2. Danh sách học sinh
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: AppLoading());
                }
                
                if (controller.filteredStudents.isEmpty) {
                  return _buildEmptyState();
                }
                
                return RefreshIndicator(
                  onRefresh: controller.fetchStudents,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.paddingL,
                      0,
                      AppConstants.paddingL,
                      AppConstants.paddingL,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: controller.filteredStudents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final student = controller.filteredStudents[index];
                      return _buildStudentCard(context, student);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: AppConstants.paddingL),
      child: AppSearchBar(
        hintText: 'Tìm kiếm học sinh...',
        controller: controller.searchController,
        onChanged: controller.filterStudents,
        onClear: () => controller.filterStudents(''),
        height: 46,
        borderRadius: BorderRadius.circular(23),
        backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        boxShadow: const [],
        iconSize: 22,
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, dynamic student) {
    final hasAvatar = student.avatarUrl != null && student.avatarUrl!.isNotEmpty;
    final isBoy = student.gender?.toLowerCase() == 'male' || student.gender?.toLowerCase() == 'nam';

    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.TEACHER_STUDENT_DETAIL,
        arguments: student,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar tròn lớn
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                backgroundImage: hasAvatar ? NetworkImage(student.avatarUrl!) : null,
                child: !hasAvatar
                    ? const Icon(
                        Icons.face_rounded,
                        size: 32,
                        color: AppColors.primary,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            
            // Thông tin chi tiết
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên bé
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Dòng giới tính & Ngày sinh
                  Row(
                    children: [
                      // Badge Giới tính
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isBoy
                              ? const Color(0xFFE3F2FD)
                              : const Color(0xFFFCE4EC),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isBoy ? Icons.male_rounded : Icons.female_rounded,
                              size: 13,
                              color: isBoy
                                  ? const Color(0xFF1E88E5)
                                  : const Color(0xFFD81B60),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isBoy ? 'Nam' : 'Nữ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isBoy
                                    ? const Color(0xFF1E88E5)
                                    : const Color(0xFFD81B60),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Ngày sinh
                      if (student.birthday != null)
                        Text(
                          DateHelper.formatDate(student.birthday),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Icon mũi tên
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.outline,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const AppEmptyState(
      title: 'Không tìm thấy học sinh nào',
      description: 'Kiểm tra lại từ khóa tìm kiếm hoặc kéo xuống để làm mới danh sách.',
      icon: Icons.people_outline_rounded,
    );
  }
}

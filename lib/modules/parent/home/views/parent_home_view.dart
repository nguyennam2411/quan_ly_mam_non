import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/parent_student_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../routes/app_routes.dart';

class ParentHomeView extends StatelessWidget {
  const ParentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.currentUser.value;
    final studentService = ParentStudentService.to;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào Phụ huynh',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // Student Selector
              _buildStudentSelector(context, studentService),

              const SizedBox(height: 24),
              
              // Status Card (Dựa trên bé đang chọn)
              Obx(() {
                final student = studentService.selectedStudent.value;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${student?.name ?? "bé"}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 32),

              // Features
              _buildFeatureSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentSelector(BuildContext context, ParentStudentService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn con',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (service.isLoading.value && service.students.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service.students.isEmpty) {
            return const Text('Không tìm thấy thông tin học sinh');
          }

          return SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: service.students.length,
              itemBuilder: (context, index) {
                final student = service.students[index];
                
                return Obx(() {
                  final isSelected = service.selectedStudent.value?.id == student.id;
                  
                  return GestureDetector(
                    onTap: () => service.selectStudent(student),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              backgroundImage: student.avatarUrl != null 
                                  ? NetworkImage(student.avatarUrl!) 
                                  : null,
                              child: student.avatarUrl == null 
                                  ? const Icon(Icons.person, color: AppColors.primary) 
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            student.name.split(' ').last,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.primary : AppColors.onSurface,
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
          );
        }),
      ],
    );
  }

  Widget _buildFeatureSection(BuildContext context) {
    final studentService = ParentStudentService.to;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiện ích',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildFeatureCard(Icons.calendar_today_rounded, 'Lịch học', () {}),
            _buildFeatureCard(Icons.restaurant_rounded, 'Thực đơn', () {
              final student = studentService.selectedStudent.value;
              if (student != null) {
                Get.toNamed(Routes.MEAL_PLAN, arguments: {
                  'gradeId': student.gradeId,
                  'title': 'Thực đơn Khối ${student.gradeName}',
                });
              } else {
                Get.snackbar('Thông báo', 'Vui lòng chọn bé để xem thực đơn');
              }
            }),
            _buildFeatureCard(Icons.assignment_ind_rounded, 'Xin nghỉ học', () {
              Get.toNamed(Routes.PARENT_LEAVE_REQUEST);
            }),
            _buildFeatureCard(Icons.history_edu_rounded, 'Nhật ký của bé', () {
              Get.toNamed(Routes.PARENT_ACTIVITY_LOG);
            }),
            _buildFeatureCard(Icons.payment_rounded, 'Học phí', () {}),
            _buildFeatureCard(Icons.timeline_rounded, 'Chuyên cần', () {
              Get.toNamed(Routes.PARENT_ATTENDANCE_HISTORY);
            }),
            _buildFeatureCard(Icons.health_and_safety_rounded, 'Sức khoẻ bé', () {
              Get.toNamed(Routes.PARENT_HEALTH);
            }), // <--- MÌNH ĐÃ THÊM DẤU ĐÓNG NGOẶC BỊ THIẾU Ở ĐÂY
            _buildFeatureCard(Icons.medication_rounded, 'Dặn thuốc', () {
              Get.toNamed(Routes.PARENT_MEDICATION_REQUEST);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

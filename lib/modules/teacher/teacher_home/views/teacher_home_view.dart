import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_database.dart';
import '../../../../routes/app_routes.dart';
import '../../../../global_widgets/home/home_section_header.dart';
import '../../../../global_widgets/home/home_welcome_header.dart';
import '../../../../global_widgets/home/quick_feature_card.dart';
import '../../../../global_widgets/buttons/action_pill_button.dart';
import '../controllers/teacher_home_controller.dart';

class TeacherHomeView extends GetView<TeacherHomeController> {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              HomeWelcomeHeader(
                userName: AuthService.to.userProfile[AppDatabase.colName] ?? 'Giáo viên',
              ),

              const SizedBox(height: 24),

              // Classroom Info Card
              _buildClassroomCard(context),

              const SizedBox(height: 32),

              // Utilities Section
              const HomeSectionHeader(title: 'Tiện ích hệ thống'),
              const SizedBox(height: 16),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
                children: [
                  QuickFeatureCard(
                    icon: Icons.assignment_turned_in_rounded,
                    label: 'Điểm danh',
                    onTap: () async {
                      await Get.toNamed(Routes.ATTENDANCE_MAIN);
                      controller.fetchClassroomStats();
                    },
                  ),
                  QuickFeatureCard(
                    icon: Icons.event_busy_rounded,
                    label: 'Nghỉ phép',
                    onTap: () => Get.toNamed(Routes.TEACHER_LEAVE_REQUEST),
                  ),
                  QuickFeatureCard(
                    icon: Icons.medication_rounded,
                    label: 'Dặn thuốc',
                    onTap: () => Get.toNamed(Routes.TEACHER_MEDICATION_REQUEST),
                  ),
                  QuickFeatureCard(
                    icon: Icons.history_edu_rounded,
                    label: 'Nhật ký',
                    onTap: () => Get.toNamed(Routes.TEACHER_ACTIVITY_LOG),
                  ),
                  QuickFeatureCard(
                    icon: Icons.event_note_rounded,
                    label: 'Lịch dạy',
                    onTap: () => Get.toNamed(Routes.TEACHER_SCHEDULE),
                  ),
                  QuickFeatureCard(
                    icon: Icons.restaurant_menu_rounded,
                    label: 'Thực đơn',
                    onTap: () => Get.toNamed(Routes.MEAL_PLAN, arguments: {
                      'gradeId': AuthService.to.gradeId.value,
                      'title': 'Thực đơn của lớp',
                    }),
                  ),
                  QuickFeatureCard(
                    icon: Icons.payment_rounded,
                    label: 'Học phí',
                    onTap: () => Get.toNamed(Routes.TEACHER_INVOICE),
                  ),
                  QuickFeatureCard(
                    icon: Icons.monitor_heart_rounded,
                    label: 'Sức khỏe',
                    onTap: () => Get.toNamed(Routes.TEACHER_HEALTH),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassroomCard(BuildContext context) {
    return Obx(() {
      final total = controller.totalStudents.value;
      final present = controller.presentStudents.value;
      final percent = controller.attendancePercentage;
      final percentInt = (percent * 100).toInt();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryContainer,
              AppColors.primaryContainer.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: AppColors.onPrimaryContainer,
                  size: 32,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  child: Text(
                    'LỚP HỌC HIỆN TẠI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onPrimaryContainer.withOpacity(0.8),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Classroom Name
                Text(
                  controller.classroomName.isNotEmpty ? controller.classroomName : 'Đang tải...',
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sĩ số: $present / $total học sinh',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      '$percentInt%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.onPrimaryContainer),
                  ),
                ),
                const SizedBox(height: 24),
                // Action Button
                ActionPillButton(
                  icon: Icons.arrow_forward_rounded,
                  label: 'Chi tiết lớp học',
                  onTap: () async {
                    await Get.toNamed(Routes.ATTENDANCE_MAIN);
                    controller.fetchClassroomStats();
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
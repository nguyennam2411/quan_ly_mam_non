import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/parent_student_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_database.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/home_section_header.dart';
import '../widgets/quick_feature_card.dart';
import '../widgets/home_welcome_header.dart';
import '../../../../global_widgets/buttons/action_pill_button.dart';
import '../../../../global_widgets/dialogs/app_loading.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/values/app_strings.dart';

class ParentHomeView extends StatelessWidget {
  const ParentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
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
              HomeWelcomeHeader(
                userName: AuthService.to.userProfile[AppDatabase.colName] ?? AppStrings.labelParent,
              ),
              
              const SizedBox(height: 24),

              // Student Selector
              _buildStudentSelector(context, studentService),

              const SizedBox(height: 24),
              
              // Status Card (Dựa trên bé đang chọn)
              Obx(() {
                final student = studentService.selectedStudent.value;
                if (student == null) return const SizedBox.shrink();

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decoration Icon
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.child_care_rounded,
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
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              AppStrings.studentInfo,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onPrimaryContainer,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // Avatar
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.onPrimaryContainer.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                                  backgroundImage: student.avatarUrl != null
                                      ? NetworkImage(student.avatarUrl!)
                                      : null,
                                  child: student.avatarUrl == null
                                      ? const Icon(Icons.person,
                                          size: 35, color: AppColors.onPrimaryContainer)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.name,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.cake_rounded,
                                            size: 16, color: AppColors.onPrimaryContainer),
                                        const SizedBox(width: 8),
                                        Text(
                                          student.birthday != null
                                              ? DateHelper.formatDate(student.birthday!)
                                              : AppStrings.notUpdated,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.onPrimaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.school_rounded,
                                            size: 16, color: AppColors.onPrimaryContainer),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${AppStrings.classLabel} ${student.classroomName ?? "..."}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.onPrimaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ActionPillButton(
                                  icon: Icons.qr_code_rounded,
                                  label: AppStrings.labelStudentQr,
                                  onTap: () => Get.toNamed(Routes.PARENT_STUDENT_QR, arguments: student.id),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ActionPillButton(
                                  icon: Icons.person_pin_rounded,
                                  label: AppStrings.labelProfile,
                                  onTap: () {
                                    Get.toNamed(
                                      Routes.PARENT_STUDENT_PROFILE_DETAIL,
                                      arguments: student,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
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
          AppStrings.selectChild,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (service.isLoading.value && service.students.isEmpty) {
            return const AppLoading(size: 24);
          }

          if (service.students.isEmpty) {
            return const Text(AppStrings.noStudentInfo);
          }

          return SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: service.students.length,
              clipBehavior: Clip.none,
              itemBuilder: (context, index) {
                final student = service.students[index];

                return Obx(() {
                  final isSelected = service.selectedStudent.value?.id == student.id;

                  return GestureDetector(
                    onTap: () => service.selectStudent(student),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              backgroundImage: student.avatarUrl != null
                                  ? NetworkImage(student.avatarUrl!)
                                  : null,
                              child: student.avatarUrl == null
                                  ? Icon(Icons.person,
                                      size: 16,
                                      color: isSelected ? AppColors.primary : AppColors.primary)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            student.name.split(' ').last,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.onSurface,
                            ),
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

  void _runWithStudentGuard(ParentStudentService service, VoidCallback action) {
    final student = service.selectedStudent.value;
    if (student == null) {
      AppDialogs.warning(message: AppStrings.errorNoStudentSelected);
      return;
    }
    if (student.classroomId == null || student.classroomId!.isEmpty) {
      AppDialogs.warning(message: AppStrings.errorStudentNoClass);
      return;
    }
    action();
  }

  Widget _buildFeatureSection(BuildContext context) {
    final studentService = ParentStudentService.to;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionHeader(title: AppStrings.homeUtilities),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
          children: [
            QuickFeatureCard(
              icon: Icons.schedule_rounded,
              label: AppStrings.menuParentSchedule,
              onTap: () => _runWithStudentGuard(
                studentService,
                () => Get.toNamed(Routes.PARENT_STUDENT_SCHEDULE),
              ),
            ),
            QuickFeatureCard(
              icon: Icons.restaurant_rounded,
              label: AppStrings.menuMeals,
              onTap: () => _runWithStudentGuard(
                studentService,
                () {
                  final student = studentService.selectedStudent.value!;
                  Get.toNamed(Routes.MEAL_PLAN, arguments: {
                    'gradeId': student.gradeId,
                    'title': '${AppStrings.menuMeals} Khối ${student.gradeName}',
                  });
                },
              ),
            ),
            QuickFeatureCard(
              icon: Icons.assignment_ind_rounded,
              label: AppStrings.menuLeaveRequest,
              onTap: () => _runWithStudentGuard(
                studentService,
                () => Get.toNamed(Routes.PARENT_LEAVE_REQUEST),
              ),
            ),
            QuickFeatureCard(
              icon: Icons.history_edu_rounded,
              label: AppStrings.menuLog,
              onTap: () => _runWithStudentGuard(
                studentService,
                () => Get.toNamed(Routes.PARENT_ACTIVITY_LOG),
              ),
            ),
            QuickFeatureCard(
              icon: Icons.payment_rounded,
              label: AppStrings.menuInvoice,
              onTap: () => _runWithStudentGuard(
                studentService,
                () => Get.toNamed(Routes.PARENT_INVOICE),
              ),
            ),
            QuickFeatureCard(
              icon: Icons.timeline_rounded,
              label: AppStrings.menuAttendanceHistory,
              onTap: () => _runWithStudentGuard(
                studentService,
                () => Get.toNamed(Routes.PARENT_ATTENDANCE_HISTORY),
              ),
            ),
            QuickFeatureCard(
              icon: Icons.health_and_safety_rounded,
              label: AppStrings.menuHealth,
              onTap: () => _runWithStudentGuard(
                studentService,
                () => Get.toNamed(Routes.PARENT_HEALTH),
              ),
            ),
            QuickFeatureCard(
              icon: Icons.medication_rounded,
              label: AppStrings.menuMedication,
              onTap: () => _runWithStudentGuard(
                studentService,
                () => Get.toNamed(Routes.PARENT_MEDICATION_REQUEST),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

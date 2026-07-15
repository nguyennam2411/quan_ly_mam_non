import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../../../../global_widgets/state/app_loading.dart';
import '../controllers/teacher_talent_attendance_controller.dart';
import '../../../../core/values/app_database.dart';

class TeacherTalentAttendanceView extends GetView<TeacherTalentAttendanceController> {
  const TeacherTalentAttendanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(
        title: 'Điểm danh: ${controller.talentClass.name}',
        backgroundColor: AppColors.primary,
        titleColor: Colors.white,
        iconColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
           return const AppLoading();
        }

        if (controller.enrolledStudents.isEmpty) {
          return const AppEmptyState(
            title: 'Lớp trống',
            description: 'Hiện chưa có bé nào đăng ký học lớp này.',
            icon: Icons.person_off_rounded,
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.enrolledStudents.length,
                itemBuilder: (context, index) {
                  final student = controller.enrolledStudents[index];
                  final status = controller.attendanceRecords[student.id!] ?? AppDatabase.statusPresent;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null,
                          child: student.avatarUrl == null ? const Icon(Icons.person, size: 28) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.onSurface),
                              ),
                              const SizedBox(height: 12),
                              Obx(() {
                                final currentStatus = controller.attendanceRecords[student.id!] ?? AppDatabase.statusPresent;
                                return Row(
                                  children: [
                                    _buildStatusButton(
                                      studentId: student.id!,
                                      currentStatus: currentStatus,
                                      targetStatus: AppDatabase.statusPresent,
                                      label: 'Có mặt',
                                      icon: Icons.check_circle_outline,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatusButton(
                                      studentId: student.id!,
                                      currentStatus: currentStatus,
                                      targetStatus: AppDatabase.statusAbsentExcused,
                                      label: 'Phép',
                                      icon: Icons.watch_later_outlined,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildStatusButton(
                                      studentId: student.id!,
                                      currentStatus: currentStatus,
                                      targetStatus: AppDatabase.statusAbsentUnexcused,
                                      label: 'Vắng',
                                      icon: Icons.highlight_off,
                                      color: Colors.red,
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => controller.submitAttendance(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lưu điểm danh', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatusButton({
    required String studentId,
    required String currentStatus,
    required String targetStatus,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = currentStatus == targetStatus;
    return Expanded(
      child: InkWell(
        onTap: () => controller.updateAttendance(studentId, targetStatus),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.white,
            border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
                : [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Icon(icon, key: ValueKey(isSelected), color: isSelected ? color : Colors.grey[400], size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey[500],
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

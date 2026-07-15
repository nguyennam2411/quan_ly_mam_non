import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/state/app_loading.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../controllers/teacher_talent_attendance_controller.dart';

class TeacherTalentStudentListView extends GetView<TeacherTalentAttendanceController> {
  const TeacherTalentStudentListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(
        title: 'Sĩ số: ${controller.talentClass.name}',
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
            icon: Icons.group_off_outlined,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.enrolledStudents.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final student = controller.enrolledStudents[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              leading: CircleAvatar(
                radius: 28,
                backgroundImage: student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null,
                child: student.avatarUrl == null ? const Icon(Icons.person, size: 28) : null,
              ),
              title: Text(
                student.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.onSurface),
              ),
              subtitle: Text(
                'Lớp chính khóa: ${student.classroomName ?? "Chưa xếp lớp"}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Đang học', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            );
          },
        );
      }),
    );
  }
}

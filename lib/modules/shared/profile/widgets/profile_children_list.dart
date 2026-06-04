import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/services/parent_student_service.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';

import 'package:quan_ly_mam_non/core/values/app_strings.dart';
import '../../../../routes/app_routes.dart';

/// Danh sách hồ sơ bé dạng card dọc, bo góc giống như một nhóm Cài đặt.
class ProfileChildrenList extends StatelessWidget {
  const ProfileChildrenList({super.key});

  @override
  Widget build(BuildContext context) {
    final studentService = ParentStudentService.to;

    return Obx(() {
      final students = studentService.students;
      if (students.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 18.0, bottom: 8.0),
            child: Text(
              AppStrings.profileChildrenListTitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.15),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.015),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: List.generate(students.length * 2 - 1, (index) {
                  if (index.isOdd) {
                    return const _ChildItemDivider();
                  }
                  final studentIndex = index ~/ 2;
                  final student = students[studentIndex];

                  return _ProfileChildItem(
                    name: student.name,
                    classroomName: student.classroomName ?? AppStrings.profileUnassignedChildClass,
                    avatarUrl: student.avatarUrl,
                    onTap: () {
                      Get.toNamed(
                        Routes.PARENT_STUDENT_PROFILE_DETAIL,
                        arguments: student,
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// Widget dòng hiển thị thông tin từng bé chuyển trang (không có nút chọn).
class _ProfileChildItem extends StatelessWidget {
  final String name;
  final String classroomName;
  final String? avatarUrl;
  final VoidCallback onTap;

  const _ProfileChildItem({
    required this.name,
    required this.classroomName,
    this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tông màu chủ đạo của Phụ huynh
    const parentAccent = AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              // Avatar của bé dạng CircleAvatar
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: parentAccent.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: parentAccent.withValues(alpha: 0.08),
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? const Icon(
                          Icons.face_rounded,
                          size: 20,
                          color: parentAccent,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // Thông tin bé
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppStrings.classLabel} $classroomName',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron-right arrow để biểu thị hành động xem chi tiết
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Đường gạch phân cách giữa các dòng bé.
class _ChildItemDivider extends StatelessWidget {
  const _ChildItemDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 76, // Căn lề thẳng hàng với Text sau Avatar
      endIndent: 16,
      color: AppColors.outlineVariant.withValues(alpha: 0.15),
    );
  }
}

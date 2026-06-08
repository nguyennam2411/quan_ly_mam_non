import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/services/auth_service.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_database.dart';
import 'package:quan_ly_mam_non/core/values/user_role.dart';
import 'package:quan_ly_mam_non/core/utils/dialog.dart';
import 'package:quan_ly_mam_non/core/values/app_strings.dart';
import '../controllers/profile_controller.dart';

/// Thẻ profile dạng card trắng, đổ bóng nhẹ, căn giữa avatar + tên + lớp.
class ProfileIdCard extends StatelessWidget {
  const ProfileIdCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Obx(() {
      final authService = AuthService.to;
      final user = authService.currentUser.value;
      final isTeacher = UserRole.isTeacher(authService.userRole.value);
      final userName = authService.userProfile[AppDatabase.colName]?.toString() ?? '';
      final classroom = authService.classroomName.value;
      final avatarUrl = authService.userProfile[AppDatabase.colAvatarUrl]?.toString();

      final initials = _getInitials(userName.isNotEmpty ? userName : (user?.email ?? ''));
      final subtitleText = isTeacher
          ? (classroom.isNotEmpty ? '${AppStrings.classLabel} $classroom' : AppStrings.profileUnassignedClass)
          : (user?.email ?? '');

      // Màu accent nhẹ cho avatar background theo role
      final avatarAccent = isTeacher
          ? AppColors.primary
          : AppColors.secondary;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             // Avatar dạng chạm để đổi kèm nút camera nhỏ
            GestureDetector(
              onTap: () async {
                final source = await AppDialogs.showImageSourcePicker(
                  title: AppStrings.profileChangeAvatarTitle,
                );
                if (source != null) {
                  profileController.updateAvatar(source);
                }
              },
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: avatarAccent.withValues(alpha: 0.3),
                        width: 2.5,
                      ),
                    ),
                    child: Obx(() {
                      final isUploading = profileController.isLoading.value;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: avatarAccent.withValues(alpha: 0.1),
                            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl == null || avatarUrl.isEmpty
                                ? Text(
                                    initials,
                                    style: TextStyle(
                                      color: avatarAccent,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          if (isUploading)
                            Container(
                              width: 88,
                              height: 88,
                              decoration: const BoxDecoration(
                                color: Colors.black38,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: avatarAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Họ và tên
            Text(
              userName.isNotEmpty ? userName : AppStrings.profileUnassignedName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Subtitle (lớp / email)
            if (subtitleText.isNotEmpty)
              Text(
                subtitleText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      );
    });
  }

  String _getInitials(String nameOrEmail) {
    if (nameOrEmail.isEmpty) return '?';
    return nameOrEmail[0].toUpperCase();
  }
}

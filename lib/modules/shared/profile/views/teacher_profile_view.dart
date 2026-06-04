import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/services/auth_service.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_database.dart';
import 'package:quan_ly_mam_non/core/utils/dialog.dart';
import 'package:quan_ly_mam_non/core/values/app_strings.dart';
import '../widgets/profile_id_card.dart';
import '../widgets/profile_setting_section.dart';
import '../widgets/profile_logout_button.dart';

class TeacherProfileView extends StatelessWidget {
  const TeacherProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Thẻ ID gradient (Xanh / Ngọc)
              const ProfileIdCard(),

              // 2. Thông tin tài khoản
              Obx(() => ProfileSettingSection(
                title: AppStrings.profileInfoTitle,
                children: [
                  ProfileSettingItem(
                    icon: Icons.person_outline_rounded,
                    title: AppStrings.profileFullName,
                    subtitle: AuthService.to.userProfile[AppDatabase.colName]?.toString() ?? AppStrings.notUpdated,
                  ),
                  const ProfileSettingDivider(),
                  ProfileSettingItem(
                    icon: Icons.mail_outline_rounded,
                    title: AppStrings.profileEmail,
                    subtitle: AuthService.to.currentUser.value?.email ?? '—',
                  ),
                  const ProfileSettingDivider(),
                  ProfileSettingItem(
                    icon: Icons.school_outlined,
                    title: AppStrings.profileClassroom,
                    subtitle: AuthService.to.classroomName.value.isNotEmpty
                        ? AuthService.to.classroomName.value
                        : AppStrings.profileUnassignedClass,
                  ),
                ],
              )),



              // 4. Thông tin ứng dụng
              ProfileSettingSection(
                title: AppStrings.profileAppInfo,
                children: [
                  ProfileSettingItem(
                    icon: Icons.call_outlined,
                    title: AppStrings.profileContactSchool,
                    subtitle: AppStrings.profileSupportTeacher,
                    onTap: () {
                      AppDialogs.info(message: AppStrings.profileSchoolHotlineInfo);
                    },
                  ),
                  const ProfileSettingDivider(),
                  ProfileSettingItem(
                    icon: Icons.info_outline_rounded,
                    title: AppStrings.profileTermsOfUse,
                    subtitle: AppStrings.profileTermsDesc,
                    onTap: () {
                      AppDialogs.info(message: AppStrings.profileVersionInfo);
                    },
                  ),
                ],
              ),

              // 5. Nút đăng xuất
              const ProfileLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}

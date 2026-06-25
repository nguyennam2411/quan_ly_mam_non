import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/services/auth_service.dart';
import 'package:quan_ly_mam_non/core/services/parent_student_service.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_database.dart';
import 'package:quan_ly_mam_non/core/utils/dialog.dart';
import 'package:quan_ly_mam_non/core/values/app_strings.dart';
import '../widgets/profile_id_card.dart';
import '../widgets/profile_setting_section.dart';
import '../widgets/profile_children_list.dart';
import '../widgets/profile_logout_button.dart';

class ParentProfileView extends StatelessWidget {
  const ParentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Thẻ ID gradient (Xanh / Tím)
              const ProfileIdCard(),

              // 2. Danh sách con
              if (Get.isRegistered<ParentStudentService>())
                const ProfileChildrenList(),

              // 3. Thông tin tài khoản
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
                    icon: Icons.phone_android_rounded,
                    title: AppStrings.profilePhone,
                    subtitle: AuthService.to.userProfile['phone']?.toString() ?? AppStrings.notUpdated,
                  ),
                ],
              )),



              // 5. Thông tin ứng dụng
              ProfileSettingSection(
                title: AppStrings.profileAppInfo,
                children: [
                  ProfileSettingItem(
                    icon: Icons.call_outlined,
                    title: AppStrings.profileContactSchool,
                    subtitle: AppStrings.profileSupportParent,
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

              // 6. Nút đăng xuất
              const ProfileLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}

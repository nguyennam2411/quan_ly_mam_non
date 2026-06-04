import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/services/auth_service.dart';
import 'package:quan_ly_mam_non/core/values/user_role.dart';
import 'package:quan_ly_mam_non/modules/shared/profile/views/teacher_profile_view.dart';
import 'package:quan_ly_mam_non/modules/shared/profile/views/parent_profile_view.dart';
import 'package:quan_ly_mam_non/modules/shared/home/views/parent_home_view.dart';
import 'package:quan_ly_mam_non/modules/shared/home/views/teacher_home_view.dart';
import 'package:quan_ly_mam_non/modules/shared/notifications/views/notification_view.dart';

import 'package:quan_ly_mam_non/global_widgets/dialogs/app_loading.dart';
import 'package:quan_ly_mam_non/core/values/app_strings.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;

  // Quyết định danh sách trang dựa trên Role
  List<Widget> get pages {
    final role = AuthService.to.userRole.value;
    
    // Sử dụng View tương ứng cho tab Home (index 0)
    if (UserRole.isTeacher(role)) {
      return [
        const TeacherHomeView(), 
        const SizedBox(), 
        const NotificationView(), 
        const TeacherProfileView()
      ];
    } else if (UserRole.isParent(role)) {
      return [
        const ParentHomeView(), 
        const SizedBox(), 
        const NotificationView(), 
        const ParentProfileView()
      ];
    } else {
      return [
        const Scaffold(
          body: AppLoading(),
        ),
        const SizedBox(), 
        const NotificationView(), 
        const Scaffold(
          body: Center(
            child: Text(AppStrings.loadingData),
          ),
        ),
      ];
    }
  }

  void changePage(int index) => currentIndex.value = index;
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/services/auth_service.dart';
import 'package:quan_ly_mam_non/core/values/user_role.dart';
import 'package:quan_ly_mam_non/modules/shared/profile/profile_view.dart';
import 'package:quan_ly_mam_non/modules/parent/home/views/parent_home_view.dart';
import 'package:quan_ly_mam_non/modules/teacher/teacher_home/views/teacher_home_view.dart';
import 'package:quan_ly_mam_non/modules/shared/notifications/views/notification_view.dart';

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
        const ProfileView()
      ];
    } else {
      return [
        const ParentHomeView(), 
        const SizedBox(), 
        const NotificationView(), 
        const ProfileView()
      ];
    }
  }

  void changePage(int index) => currentIndex.value = index;
}
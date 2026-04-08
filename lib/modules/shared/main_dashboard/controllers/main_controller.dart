import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/services/auth_service.dart';
import 'package:quan_ly_mam_non/core/values/user_role.dart';
import 'package:quan_ly_mam_non/modules/shared/profile/profile_view.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;

  // Quyết định danh sách trang dựa trên Role
  List<Widget> get pages {
    final role = AuthService.to.userRole.value;
    
    // Hiện tại cả 2 role đều dùng chung 1 layout placeholder
    // Sau này sẽ thay thế bằng các View thực tế (DashboardTeacher, DashboardParent, ...)
    if (UserRole.isTeacher(role)) {
      return [const SizedBox(), const SizedBox(), const SizedBox(), const ProfileView()];
    } else {
      return [const SizedBox(), const SizedBox(), const SizedBox(), const ProfileView()];
    }
  }

  void changePage(int index) => currentIndex.value = index;
}
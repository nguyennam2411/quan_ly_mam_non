import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

import '../modules/shared/main_dashboard/bindings/main_binding.dart';
import '../modules/shared/main_dashboard/views/main_view.dart';

// Các màn hình Auth (Tạm thời import trống hoặc comment lại nếu file chưa tồn tại để tránh lỗi compile)
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
// import '../modules/auth/forgot_password/views/reset_password_view.dart';
import '../modules/auth/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/auth/forgot_password/views/forgot_password_view.dart';
import '../modules/auth/forgot_password/views/otp_verification_view.dart';
import '../modules/auth/forgot_password/views/reset_password_view.dart';

import '../modules/teacher/attendance/bindings/attendance_binding.dart';
import '../modules/teacher/attendance/views/attendance_main_view.dart';
import '../modules/teacher/attendance/views/attendance_list_view.dart';
import '../modules/teacher/attendance/views/attendance_history_view.dart';
import '../modules/parent/leave_request/bindings/parent_leave_request_binding.dart';
import '../modules/parent/leave_request/views/parent_leave_request_view.dart';
import '../modules/parent/leave_request/views/create_leave_request_view.dart';
import '../modules/teacher/leave_request/bindings/teacher_leave_request_binding.dart';
import '../modules/teacher/leave_request/views/teacher_leave_request_view.dart';

class AppPages {
  // Màn hình khởi đầu khi mở App
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    // 1. Màn hình Splash
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // 2. Màn hình Đăng nhập
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),

    // 3. Cụm Quên mật khẩu
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.OTP_VERIFY,
      page: () => const OtpVerificationView(),
      binding: ForgotPasswordBinding(), // Dùng chung Binding để giữ Controller cũ
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => const ResetPasswordView(),
      binding: ForgotPasswordBinding(),
    ),

    // 4. Các màn hình chính (Dùng chung Dashboard Shell)
    GetPage(
      name: Routes.MAIN_DASHBOARD,
      page: () => const MainView(),
      binding: MainBinding(),
    ),

    // 5. Tính năng Điểm danh
    GetPage(
      name: Routes.ATTENDANCE_MAIN,
      page: () => const AttendanceMainView(),
      binding: AttendanceBinding(),
    ),
    GetPage(
      name: Routes.ATTENDANCE_LIST,
      page: () => const AttendanceListView(),
      binding: AttendanceBinding(),
    ),
    GetPage(
      name: Routes.ATTENDANCE_HISTORY,
      page: () => const AttendanceHistoryView(),
      binding: AttendanceBinding(),
    ),
    
    // 6. Tính năng Phụ huynh
    GetPage(
      name: Routes.PARENT_LEAVE_REQUEST,
      page: () => const ParentLeaveRequestView(),
      binding: ParentLeaveRequestBinding(),
    ),
    GetPage(
      name: Routes.PARENT_CREATE_LEAVE_REQUEST,
      page: () => const CreateLeaveRequestView(),
      binding: ParentLeaveRequestBinding(),
    ),

    // 7. Chức năng Giáo viên (Tiếp tục)
    GetPage(
      name: Routes.TEACHER_LEAVE_REQUEST,
      page: () => const TeacherLeaveRequestView(),
      binding: TeacherLeaveRequestBinding(),
    ),
  ];
}
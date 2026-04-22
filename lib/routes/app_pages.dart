import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'app_routes.dart';

// Common & Shared
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/shared/main_dashboard/bindings/main_binding.dart';
import '../modules/shared/main_dashboard/views/main_view.dart';
import '../modules/shared/meal_plans/bindings/meal_plan_binding.dart';
import '../modules/shared/meal_plans/views/meal_plan_view.dart';

// Auth
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/auth/forgot_password/views/forgot_password_view.dart';
import '../modules/auth/forgot_password/views/otp_verification_view.dart';
import '../modules/auth/forgot_password/views/reset_password_view.dart';

// Teacher
import '../modules/teacher/attendance/bindings/attendance_binding.dart';
import '../modules/teacher/attendance/views/attendance_main_view.dart';
import '../modules/teacher/attendance/views/attendance_list_view.dart';
import '../modules/teacher/attendance/views/attendance_history_view.dart';
import '../modules/teacher/attendance/views/attendance_statistic_view.dart';
import '../modules/teacher/leave_request/bindings/teacher_leave_request_binding.dart';
import '../modules/teacher/leave_request/views/teacher_leave_request_view.dart';
import '../modules/teacher/activity_log/bindings/teacher_activity_log_binding.dart';
import '../modules/teacher/activity_log/views/teacher_activity_log_view.dart';
import '../modules/teacher/activity_log/views/add_activity_log_view.dart';

// Parent
import '../modules/parent/attendance_history/bindings/attendance_history_binding.dart';
import '../modules/parent/attendance_history/views/attendance_history_view.dart' as parent_history;
import '../modules/parent/leave_request/bindings/parent_leave_request_binding.dart';
import '../modules/parent/leave_request/views/parent_leave_request_view.dart';
import '../modules/parent/leave_request/views/create_leave_request_view.dart';
import '../modules/parent/activity_log/bindings/parent_activity_log_binding.dart';
import '../modules/parent/activity_log/views/parent_activity_log_view.dart';
import '../modules/parent/health/bindings/parent_health_binding.dart';
import '../modules/parent/health/views/parent_health_view.dart';

// Teacher Health
import '../modules/teacher/health/bindings/health_binding.dart';
import '../modules/teacher/health/views/health_input_view.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    // 1. Splash
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // 2. Auth
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.OTP_VERIFY,
      page: () => const OtpVerificationView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => const ResetPasswordView(),
      binding: ForgotPasswordBinding(),
    ),

    // 3. Main Dashboard
    GetPage(
      name: Routes.MAIN_DASHBOARD,
      page: () => const MainView(),
      binding: MainBinding(),
    ),

    // 4. Teacher Attendance
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
    GetPage(
      name: Routes.ATTENDANCE_STATISTIC,
      page: () => const AttendanceStatisticView(),
      binding: AttendanceBinding(),
    ),

    // 5. Teacher Leave Request
    GetPage(
      name: Routes.TEACHER_LEAVE_REQUEST,
      page: () => const TeacherLeaveRequestView(),
      binding: TeacherLeaveRequestBinding(),
    ),

    // 6. Teacher Activity Log
    GetPage(
      name: Routes.TEACHER_ACTIVITY_LOG,
      page: () => const TeacherActivityLogView(),
      binding: TeacherActivityLogBinding(),
    ),
    GetPage(
      name: Routes.TEACHER_ADD_ACTIVITY_LOG,
      page: () => const AddActivityLogView(),
      binding: TeacherActivityLogBinding(),
    ),

    // 7. Parent Attendance History
    GetPage(
      name: Routes.PARENT_ATTENDANCE_HISTORY,
      page: () => const parent_history.AttendanceHistoryView(),
      binding: AttendanceHistoryBinding(),
    ),

    // 8. Parent Leave Request
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

    // 9. Parent Activity Log
    GetPage(
      name: Routes.PARENT_ACTIVITY_LOG,
      page: () => const ParentActivityLogView(),
      binding: ParentActivityLogBinding(),
    ),

    // 10. Shared Meal Plan
    GetPage(
      name: Routes.MEAL_PLAN,
      page: () => const MealPlanView(),
      binding: MealPlanBinding(),
    ),

    // 11. Teacher Health
    GetPage(
      name: Routes.TEACHER_HEALTH,
      page: () => const HealthInputView(),
      binding: HealthBinding(),
    ),

    // 12. Parent Health
    GetPage(
      name: Routes.PARENT_HEALTH,
      page: () => const ParentHealthView(),
      binding: ParentHealthBinding(),
    ),
  ];
}

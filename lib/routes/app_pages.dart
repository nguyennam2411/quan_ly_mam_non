import 'package:get/get.dart';
import 'app_routes.dart';

// --- Common & Shared ---
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/shared/main_dashboard/bindings/main_binding.dart';
import '../modules/shared/main_dashboard/views/main_view.dart';
import '../modules/shared/meal_plans/bindings/meal_plan_binding.dart';
import '../modules/shared/meal_plans/views/meal_plan_view.dart';

// --- Auth ---
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/auth/forgot_password/views/forgot_password_view.dart';
import '../modules/auth/forgot_password/views/otp_verification_view.dart';
import '../modules/auth/forgot_password/views/reset_password_view.dart';

// --- Teacher ---
import '../modules/teacher/attendance/bindings/attendance_binding.dart';
import '../modules/teacher/attendance/views/attendance_main_view.dart';
import '../modules/teacher/attendance/views/attendance_list_view.dart';
import '../modules/teacher/attendance/views/attendance_history_view.dart';
import '../modules/teacher/attendance/views/attendance_statistic_view.dart';
import '../modules/teacher/attendance/views/qr_scanner_view.dart';

import '../modules/teacher/leave_request/bindings/teacher_leave_request_binding.dart';
import '../modules/teacher/leave_request/views/teacher_leave_request_view.dart';

import '../modules/teacher/medication_request/bindings/teacher_medication_request_binding.dart';
import '../modules/teacher/medication_request/views/teacher_medication_request_view.dart';

import '../modules/teacher/activity_log/bindings/teacher_activity_log_binding.dart';
import '../modules/teacher/activity_log/views/teacher_activity_log_view.dart';
import '../modules/teacher/activity_log/views/add_activity_log_view.dart';

import '../modules/teacher/health/bindings/health_binding.dart';
import '../modules/teacher/health/views/health_input_view.dart';

import '../modules/teacher/invoice/bindings/teacher_invoice_binding.dart';
import '../modules/teacher/invoice/views/teacher_invoice_view.dart';

// Schedules & Lessons
import '../modules/teacher/schedule_management/bindings/schedule_mgmt_binding.dart';
import '../modules/teacher/schedule_management/views/schedule_mgmt_view.dart';
import '../modules/teacher/schedule_management/views/lesson_editor_view.dart';

// --- Parent ---
import '../modules/parent/attendance_history/bindings/attendance_history_binding.dart';
import '../modules/parent/attendance_history/views/attendance_history_view.dart' as parent_history;

import '../modules/parent/leave_request/bindings/parent_leave_request_binding.dart';
import '../modules/parent/leave_request/views/parent_leave_request_view.dart';
import '../modules/parent/leave_request/views/create_leave_request_view.dart';

import '../modules/parent/medication_request/bindings/parent_medication_request_binding.dart';
import '../modules/parent/medication_request/views/parent_medication_request_view.dart';
import '../modules/parent/medication_request/views/create_medication_request_view.dart';

import '../modules/parent/invoice/bindings/parent_invoice_binding.dart';
import '../modules/parent/invoice/views/parent_invoice_view.dart';

import '../modules/parent/activity_log/bindings/parent_activity_log_binding.dart';
import '../modules/parent/activity_log/views/parent_activity_log_view.dart';

import '../modules/parent/health/bindings/parent_health_binding.dart';
import '../modules/parent/health/views/parent_health_view.dart';

import '../modules/parent/student_schedule/bindings/student_schedule_binding.dart';
import '../modules/parent/student_schedule/views/student_schedule_view.dart';

// Student QR
import '../modules/parent/student_qr/bindings/student_qr_binding.dart';
import '../modules/parent/student_qr/views/student_qr_view.dart';

// Student Profile Detail
import '../modules/parent/student_profile/bindings/student_profile_binding.dart';
import '../modules/parent/student_profile/views/student_profile_detail_view.dart';

class AppPages {
  // Màn hình khởi đầu khi mở App
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
    GetPage(
      name: Routes.ATTENDANCE_QR,
      page: () => const QrScannerView(),
      binding: AttendanceBinding(),
    ),

    // 5. Teacher Leave Request
    GetPage(
      name: Routes.TEACHER_LEAVE_REQUEST,
      page: () => const TeacherLeaveRequestView(),
      binding: TeacherLeaveRequestBinding(),
    ),

    // 6. Teacher Medication Request
    GetPage(
      name: Routes.TEACHER_MEDICATION_REQUEST,
      page: () => const TeacherMedicationRequestView(),
      binding: TeacherMedicationRequestBinding(),
    ),

    // 7. Teacher Activity Log
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

    // 8. Teacher Health
    GetPage(
      name: Routes.TEACHER_HEALTH,
      page: () => const HealthInputView(),
      binding: HealthBinding(),
    ),

    // 8b. Teacher Invoice
    GetPage(
      name: Routes.TEACHER_INVOICE,
      page: () => const TeacherInvoiceView(),
      binding: TeacherInvoiceBinding(),
    ),

    // 9. Parent Attendance History
    GetPage(
      name: Routes.PARENT_ATTENDANCE_HISTORY,
      page: () => const parent_history.AttendanceHistoryView(),
      binding: AttendanceHistoryBinding(),
    ),

    // 10. Parent Leave Request
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

    // 11. Parent Medication Request
    GetPage(
      name: Routes.PARENT_MEDICATION_REQUEST,
      page: () => const ParentMedicationRequestView(),
      binding: ParentMedicationRequestBinding(),
    ),
    GetPage(
      name: Routes.PARENT_CREATE_MEDICATION_REQUEST,
      page: () => const CreateMedicationRequestView(),
      binding: ParentMedicationRequestBinding(),
    ),

    // 11b. Parent Invoice
    GetPage(
      name: Routes.PARENT_INVOICE,
      page: () => const ParentInvoiceView(),
      binding: ParentInvoiceBinding(),
    ),

    // 12. Parent Activity Log
    GetPage(
      name: Routes.PARENT_ACTIVITY_LOG,
      page: () => const ParentActivityLogView(),
      binding: ParentActivityLogBinding(),
    ),

    // 13. Parent Health
    GetPage(
      name: Routes.PARENT_HEALTH,
      page: () => const ParentHealthView(),
      binding: ParentHealthBinding(),
    ),

    // 14. Shared Meal Plan
    GetPage(
      name: Routes.MEAL_PLAN,
      page: () => const MealPlanView(),
      binding: MealPlanBinding(),
    ),

    // 15. Teacher Schedule Management
    GetPage(
      name: Routes.TEACHER_SCHEDULE,
      page: () => const ScheduleMgmtView(),
      binding: ScheduleMgmtBinding(),
    ),
    GetPage(
      name: Routes.TEACHER_LESSON_EDITOR,
      page: () => const LessonEditorView(),
      binding: ScheduleMgmtBinding(),
    ),

    // 16. Parent Student Schedule
    GetPage(
      name: Routes.PARENT_STUDENT_SCHEDULE,
      page: () => const StudentScheduleView(),
      binding: StudentScheduleBinding(),
    ),

    // 17. Parent Student QR
    GetPage(
      name: Routes.PARENT_STUDENT_QR,
      page: () => const StudentQrView(),
      binding: StudentQrBinding(),
    ),

    // 18. Parent Student Profile Detail
    GetPage(
      name: Routes.PARENT_STUDENT_PROFILE_DETAIL,
      page: () => const StudentProfileDetailView(),
      binding: StudentProfileBinding(),
    ),
  ];
}
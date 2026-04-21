abstract class Routes {
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  
  // Quên mật khẩu
  static const FORGOT_PASSWORD = '/forgot-password';
  static const OTP_VERIFY = '/forgot-password/otp';
  static const RESET_PASSWORD = '/forgot-password/reset';

  // Hệ thống chung (Main Dashboard)
  static const MAIN_DASHBOARD = '/dashboard';
  static const MEAL_PLAN = '/meal-plan';
  static const PARENT_ATTENDANCE_HISTORY = '/parent/attendance-history';

  // Chức năng Điểm danh (Teacher)
  static const ATTENDANCE_MAIN = '/teacher/attendance';
  static const ATTENDANCE_LIST = '/teacher/attendance/list';
  static const ATTENDANCE_HISTORY = '/teacher/attendance/history';
  static const ATTENDANCE_STATISTIC = '/teacher/attendance/statistic';
  
  // Chức năng Phụ huynh
  static const PARENT_LEAVE_REQUEST = '/parent/leave-request';
  static const PARENT_CREATE_LEAVE_REQUEST = '/parent/leave-request/create';

  // Chức năng Giáo viên (Tiếp tục)
  static const TEACHER_LEAVE_REQUEST = '/teacher/leave-request';
  static const TEACHER_ACTIVITY_LOG = '/teacher/activity-log';
  static const TEACHER_ADD_ACTIVITY_LOG = '/teacher/activity-log/add';

  // Nhật ký (Parent)
  static const PARENT_ACTIVITY_LOG = '/parent/activity-log';
}
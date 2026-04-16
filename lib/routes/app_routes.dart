abstract class Routes {
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  
  // Quên mật khẩu
  static const FORGOT_PASSWORD = '/forgot-password';
  static const OTP_VERIFY = '/forgot-password/otp';
  static const RESET_PASSWORD = '/forgot-password/reset';

  // Hệ thống chung (Main Dashboard)
  static const MAIN_DASHBOARD = '/dashboard';

  // Chức năng Điểm danh (Teacher)
  static const ATTENDANCE_MAIN = '/teacher/attendance';
  static const ATTENDANCE_LIST = '/teacher/attendance/list';
  static const ATTENDANCE_HISTORY = '/teacher/attendance/history';
  
  // Chức năng Phụ huynh
  static const PARENT_LEAVE_REQUEST = '/parent/leave-request';
  static const PARENT_CREATE_LEAVE_REQUEST = '/parent/leave-request/create';

  // Chức năng Giáo viên (Tiếp tục)
  static const TEACHER_LEAVE_REQUEST = '/teacher/leave-request';

}
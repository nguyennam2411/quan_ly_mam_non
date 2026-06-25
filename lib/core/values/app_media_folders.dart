import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class AppMediaFolders {
  AppMediaFolders._();

  // Tiền tố gốc được lấy động từ tệp .env (mặc định là 'dev')
  static String get root => 'mam-non/${dotenv.env['APP_ENV'] ?? 'dev'}';

  // 1. Thư mục ảnh đại diện
  static String userAvatar(String userId) => '$root/avatars/users/$userId';
  static String studentAvatar(String studentId) => '$root/avatars/students/$studentId';

  // 2. Thư mục đơn xin nghỉ phép
  static String leaveRequest(String studentId, String requestId) =>
      '$root/leave-requests/students/$studentId/$requestId';

  // 2.5 Thư mục đơn dặn thuốc
  static String medicationRequest(String studentId, String requestId) =>
      '$root/medication-requests/students/$studentId/$requestId';

  // 3. Thư mục bài học/bài tập giảng dạy
  static String lesson({
    required String classroomId,
    required DateTime date,
    String? scheduleId,
  }) {
    final year = date.year.toString();
    // Thêm số 0 vào tháng nếu là số có 1 chữ số để tạo cấu trúc thư mục dạng /05/06 thay vì /5/6
    final month = date.month.toString().padLeft(2, '0');
    // Nếu không có scheduleId thì là bài học tự do
    final folderName = scheduleId ?? '${DateFormat('yyyy-MM-dd').format(date)}-free';
    return '$root/lessons/classrooms/$classroomId/$year/$month/$folderName';
  }

  // 4. Thư mục nhật ký hoạt động của trẻ
  static String activity(String classroomId, String logId) =>
      '$root/activities/classrooms/$classroomId/$logId';
}




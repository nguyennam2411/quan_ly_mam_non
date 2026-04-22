import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/values/app_database.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../providers/attendance_provider.dart';

// Class này đại diện cho 1 dòng trên UI: 1 Học sinh + Trạng thái điểm danh (nếu có)
class StudentWithAttendance {
  final StudentModel student;
  AttendanceModel? attendance;

  StudentWithAttendance({required this.student, this.attendance});
}

class AttendanceRepository {
  final AttendanceProvider _provider = AttendanceProvider();
  static const Set<String> _allowedAttendanceStatuses = {
    AppDatabase.statusPresent,
    AppDatabase.statusAbsentExcused,
    AppDatabase.statusAbsentUnexcused,
  };

  Future<List<StudentWithAttendance>> getDailyAttendance(String classroomId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final List<dynamic> response = await _provider.getAttendanceData(classroomId, dateStr);

    return response.map((item) {
      final student = StudentModel.fromJson(item);
      // Sử dụng hằng số tableAttendance làm key để lấy danh sách điểm danh của học sinh
      final List<dynamic> attendanceList = item[AppDatabase.tableAttendance] ?? [];
      
      return StudentWithAttendance(
        student: student,
        attendance: attendanceList.isNotEmpty 
            ? AttendanceModel.fromJson(attendanceList.first) 
            : null,
      );
    }).toList();
  }
  Future<Map<String, bool>> getMonthlyStatus(String classroomId, DateTime month) async {
    // 1. Tính toán ngày đầu tháng và cuối tháng
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    // 2. Gọi Provider lấy data
    final List<dynamic> response = await Supabase.instance.client
        .from(AppDatabase.tableAttendance)
        .select('${AppDatabase.colDate}, ${AppDatabase.colStatus}')
        .eq(AppDatabase.colClassroomId, classroomId)
        .gte(AppDatabase.colDate, firstDay.toIso8601String().split('T')[0])
        .lte(AppDatabase.colDate, lastDay.toIso8601String().split('T')[0]);

    // 3. Logic xử lý: Group theo ngày
    Map<String, bool> statusMap = {};
    
    for (var item in response) {
      // Ép kiểu về String (yyyy-MM-dd) từ database
      final String dateStr = item[AppDatabase.colDate].toString();
      final String status = item[AppDatabase.colStatus];
      
      if (!statusMap.containsKey(dateStr)) {
        statusMap[dateStr] = true;
      }
      
      if (status == AppDatabase.statusAbsentUnexcused || status == AppDatabase.statusAbsentExcused) {
        statusMap[dateStr] = false;
      }
    }
    return statusMap;
  }

  Future<void> saveAttendanceBatch(List<AttendanceModel> list) async {
    _validateAttendanceStatuses(list);

    // Chuyển đổi sang JSON và LOẠI BỎ trường 'id' để đảm bảo tính đồng nhất của payload
    // Supabase sẽ dựa vào 'onConflict' (student_id + date) để quyết định INSERT hay UPDATE
    final data = list.map((e) {
      final map = e.toJson();
      map.remove(AppDatabase.colId); 
      return map;
    }).toList();
    
    await _provider.upsertAttendance(data);
  }

  Future<void> saveAttendance(AttendanceModel attendance) async {
    _validateAttendanceStatuses([attendance]);
    await _provider.upsertAttendance([attendance.toJson()]);
  }

  void _validateAttendanceStatuses(List<AttendanceModel> list) {
    for (final attendance in list) {
      if (_allowedAttendanceStatuses.contains(attendance.status)) {
        continue;
      }

      throw FormatException(
        'Invalid attendance status "${attendance.status}" for student ${attendance.studentId} on ${attendance.date}.',
      );
    }
  }
}

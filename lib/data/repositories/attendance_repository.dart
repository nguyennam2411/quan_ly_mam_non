import 'package:intl/intl.dart';
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


// Class này chứa kết quả sau khi check-in QR thành công
class QrCheckInResult {
  final String studentName;
  final bool isLateArrival; // true = cập nhật từ Vắng → Có mặt

  const QrCheckInResult({
    required this.studentName,
    required this.isLateArrival,
  });
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

  // Lấy dữ liệu thống kê từ hàm RPC đã được tổng hợp trên DB
  // RPC: get_attendance_stats
  Future<List<Map<String, dynamic>>> getAttendanceStatsReport({
    required String classroomId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await Supabase.instance.client.rpc(
      'get_attendance_stats_v2',
      params: {
        'p_classroom_id': classroomId,
        'p_start_date': startDate.toIso8601String().split('T')[0],
        'p_end_date': endDate.toIso8601String().split('T')[0],
      },
    );
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<AttendanceModel>> getStudentAbsentHistory(String studentId) async {
    final response = await _provider.getAbsentRecordsByStudent(studentId);
    return response.map((item) => AttendanceModel.fromJson(item)).toList();
  }

  // Check-in bằng mã QR
  // Hàm này được gọi từ màn hình quét mã QR
  Future<QrCheckInResult> checkInByQrCode({
    required String qrCode,
    required String teacherId,
    required String classroomId,
  }) async {
    final client = Supabase.instance.client;
    try {
      // 1. Tra cứu student_id từ bảng qr_tokens
      final qrData = await client
          .from(AppDatabase.tableQrTokens)
          .select(AppDatabase.colStudentId)
          .eq(AppDatabase.colCode, qrCode)
          .maybeSingle();

      if (qrData == null) throw 'Mã QR không hợp lệ';

      final String studentId = qrData[AppDatabase.colStudentId];

      // 2. Kiểm tra học sinh có thuộc lớp của giáo viên đang điểm danh không
      // Ngăn trường hợp giáo viên quét mã của học sinh lớp khác
      final studentData = await client
          .from(AppDatabase.tableStudents)
          .select('${AppDatabase.colId}, ${AppDatabase.colClassroomId}, ${AppDatabase.colName}')
          .eq(AppDatabase.colId, studentId)
          .maybeSingle();

      if (studentData == null) throw 'Không tìm thấy thông tin học sinh';

      final String studentClassroomId = studentData[AppDatabase.colClassroomId] ?? '';
      final String studentName = studentData[AppDatabase.colName] ?? 'Học sinh';

      if (studentClassroomId != classroomId) {
        throw 'Bé "$studentName" không thuộc lớp này';
      }

      // 3. Kiểm tra xem bé này hôm nay đã có bản ghi điểm danh chưa
      final today = DateTime.now().toIso8601String().split('T')[0];
      final existing = await client
          .from(AppDatabase.tableAttendance)
          .select('${AppDatabase.colId}, ${AppDatabase.colStatus}')
          .eq(AppDatabase.colStudentId, studentId)
          .eq(AppDatabase.colDate, today)
          .maybeSingle();

      final checkinTime = DateFormat('HH:mm:ss').format(DateTime.now());

      if (existing != null) {
        final String currentStatus = existing[AppDatabase.colStatus] ?? '';

        // Nếu đã PRESENT rồi thì không cần làm gì thêm
        if (currentStatus == AppDatabase.statusPresent) {
          throw 'Bé "$studentName" đã được điểm danh có mặt hôm nay';
        }

        // Nếu đang là Vắng (bé đến muộn) → cập nhật thành Có mặt
        // Đây là trường hợp: giáo viên điểm danh tay lúc đầu → bé đến muộn → quét QR
        await client
            .from(AppDatabase.tableAttendance)
            .update({
              AppDatabase.colStatus: AppDatabase.statusPresent,
              AppDatabase.colCheckinTime: checkinTime,
              AppDatabase.colMethod: AppDatabase.methodQr,
              AppDatabase.colTeacherId: teacherId,
            })
            .eq(AppDatabase.colId, existing[AppDatabase.colId]);

        return QrCheckInResult(studentName: studentName, isLateArrival: true);
      }

      // 4. Chưa có bản ghi → INSERT mới
      await client.from(AppDatabase.tableAttendance).insert({
        AppDatabase.colStudentId: studentId,
        AppDatabase.colClassroomId: classroomId,
        AppDatabase.colTeacherId: teacherId,
        AppDatabase.colDate: today,
        AppDatabase.colCheckinTime: checkinTime,
        AppDatabase.colStatus: AppDatabase.statusPresent,
        AppDatabase.colMethod: AppDatabase.methodQr,
      });

      return QrCheckInResult(studentName: studentName, isLateArrival: false);
    } catch (e) {
      rethrow;
    }
  }
}

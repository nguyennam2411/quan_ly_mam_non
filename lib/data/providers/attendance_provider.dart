import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/values/app_database.dart';

class AttendanceProvider {
  final _client = Supabase.instance.client;

  // Lấy danh sách học sinh kèm thông tin điểm danh của ngày cụ thể
  Future<List<dynamic>> getAttendanceData(String classroomId, String date) async {
    return await _client
        .from(AppDatabase.tableStudents)
        .select('*, ${AppDatabase.tableAttendance}(*)') // Kỹ thuật Join bảng của Supabase
        .eq(AppDatabase.colClassroomId, classroomId)
        .eq('${AppDatabase.tableAttendance}.${AppDatabase.colDate}', date);
  }

  // Cập nhật hoặc chèn mới bản ghi điểm danh
  Future<void> upsertAttendance(List<Map<String, dynamic>> data) async {
    // onConflict giúp Supabase biết nếu trùng student_id và date thì thực hiện UPDATE thay vì INSERT
    await _client.from(AppDatabase.tableAttendance).upsert(
      data, 
      onConflict: '${AppDatabase.colStudentId},${AppDatabase.colDate}'
    );
  }
}
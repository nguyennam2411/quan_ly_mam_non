import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/values/app_database.dart';

class ScheduleProvider {
  final _client = Supabase.instance.client;

  // Lấy TKB của một lớp theo thứ trong tuần (Lọc trực tiếp từ DB)
  Future<List<Map<String, dynamic>>> getByDay(String classroomId, int dayOfWeek) async {
    return await _client
        .from(AppDatabase.tableSchedules)
        .select()
        .eq(AppDatabase.colClassroomId, classroomId)
        .eq(AppDatabase.colDayOfWeek, dayOfWeek)
        .order(AppDatabase.colStartTime, ascending: true);
  }

  // Lấy toàn bộ TKB của một lớp (Dùng để xem tổng thể cả tuần)
  Future<List<Map<String, dynamic>>> getByClassroom(String classroomId) async {
    return await _client
        .from(AppDatabase.tableSchedules)
        .select()
        .eq(AppDatabase.colClassroomId, classroomId)
        .order(AppDatabase.colDayOfWeek, ascending: true)
        .order(AppDatabase.colStartTime, ascending: true);
  }

  // Lưu hoặc cập nhật TKB (Dành cho Giáo viên)
  Future<void> upsertSchedules(List<Map<String, dynamic>> schedules) async {
    await _client.from(AppDatabase.tableSchedules).upsert(schedules);
  }
}
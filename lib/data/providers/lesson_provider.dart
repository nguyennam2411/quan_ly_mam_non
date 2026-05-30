import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/values/app_database.dart';

class LessonProvider {
  final _client = Supabase.instance.client;

  // Lấy bài học của một lớp theo ngày cụ thể, có thể lọc theo trạng thái
  Future<List<Map<String, dynamic>>> getByDate(String classroomId, String date, {String? status}) async {
    var query = _client
        .from(AppDatabase.tableLessons)
        .select()
        .eq(AppDatabase.colClassroomId, classroomId)
        .eq(AppDatabase.colDate, date);
    
    if (status != null) {
      query = query.eq(AppDatabase.colStatus, status);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  // Lưu/Cập nhật bài học
  Future<Map<String, dynamic>> upsertLesson(Map<String, dynamic> lesson) async {
    return await _client
        .from(AppDatabase.tableLessons)
        .upsert(lesson)
        .select()
        .single();
  }
}
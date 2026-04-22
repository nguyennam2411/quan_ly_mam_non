import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/values/app_database.dart';

class HealthRecordProvider {
  final _client = Supabase.instance.client;

  /// Lấy toàn bộ lịch sử sức khỏe của một học sinh (cho biểu đồ tăng trưởng).
  Future<List<Map<String, dynamic>>> getByStudent(String studentId) async {
    return await _client
        .from(AppDatabase.tableHealthRecords)
        .select()
        .eq(AppDatabase.colStudentId, studentId)
        .order(AppDatabase.colDate, ascending: true);
  }

  /// Lấy danh sách học sinh trong lớp kèm hồ sơ sức khỏe trong một tháng.
  /// Dùng 2 query riêng biệt rồi join trong Dart để tránh lỗi embed filter.
  Future<List<Map<String, dynamic>>> getStudentsWithHealth({
    required String classroomId,
    required DateTime month,
  }) async {
    final firstDay =
        '${month.year}-${month.month.toString().padLeft(2, '0')}-01';
    final lastDayDt = DateTime(month.year, month.month + 1, 0);
    final lastDay =
        '${lastDayDt.year}-${lastDayDt.month.toString().padLeft(2, '0')}-${lastDayDt.day.toString().padLeft(2, '0')}';

    try {
      // Bước 1: Lấy danh sách học sinh của lớp
      final students = await _client
          .from(AppDatabase.tableStudents)
          .select('*')
          .eq(AppDatabase.colClassroomId, classroomId)
          .order(AppDatabase.colName);

      if (students.isEmpty) return [];

      // Bước 2: Lấy hồ sơ sức khỏe theo tháng cho tất cả học sinh trong lớp
      final studentIds =
          students.map((s) => s[AppDatabase.colId] as String).toList();

      final healthRecords = await _client
          .from(AppDatabase.tableHealthRecords)
          .select()
          .inFilter(AppDatabase.colStudentId, studentIds)
          .gte(AppDatabase.colDate, firstDay)
          .lte(AppDatabase.colDate, lastDay)
          .order(AppDatabase.colDate, ascending: true);

      // Bước 3: Gắn hồ sơ sức khỏe vào từng học sinh
      final healthMap = <String, Map<String, dynamic>>{};
      for (final record in healthRecords) {
        final sid = record[AppDatabase.colStudentId] as String;
        // Chỉ giữ record mới nhất trong tháng nếu có nhiều
        healthMap[sid] = record;
      }

      return students.map((student) {
        final sid = student[AppDatabase.colId] as String;
        return {
          ...student,
          AppDatabase.tableHealthRecords:
              healthMap.containsKey(sid) ? [healthMap[sid]!] : <Map<String, dynamic>>[],
        };
      }).toList();
    } catch (e, stack) {
      debugPrint('HealthRecordProvider error: $e\n$stack');
      rethrow;
    }
  }

  /// Lưu/cập nhật hàng loạt hồ sơ sức khỏe.
  Future<void> upsertBatch(List<Map<String, dynamic>> records) async {
    await _client
        .from(AppDatabase.tableHealthRecords)
        .upsert(
          records,
          onConflict: '${AppDatabase.colStudentId},${AppDatabase.colDate}',
        );
  }
}

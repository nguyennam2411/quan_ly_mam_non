import '../models/health_record_model.dart';
import '../providers/health_record_provider.dart';

class HealthRecordRepository {
  final HealthRecordProvider _provider;

  HealthRecordRepository({HealthRecordProvider? provider})
      : _provider = provider ?? HealthRecordProvider();

  /// Lấy danh sách học sinh cùng hồ sơ sức khỏe của tháng (dành cho Giáo viên).
  Future<List<Map<String, dynamic>>> getStudentsWithHealth({
    required String classroomId,
    required DateTime month,
  }) async {
    return await _provider.getStudentsWithHealth(
      classroomId: classroomId,
      month: month,
    );
  }

  /// Lấy lịch sử sức khỏe của một bé (dành cho biểu đồ Phụ huynh).
  Future<List<HealthRecordModel>> getStudentGrowthHistory(String studentId) async {
    final data = await _provider.getByStudent(studentId);
    return data.map((e) => HealthRecordModel.fromJson(e)).toList();
  }

  /// Lưu hàng loạt hồ sơ sức khỏe.
  Future<void> saveHealthRecords(List<Map<String, dynamic>> records) async {
    await _provider.upsertBatch(records);
  }
}

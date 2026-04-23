import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/values/app_database.dart';

class MedicationProvider {
  final _client = Supabase.instance.client;

  // Giáo viên: Lấy đơn của lớp
  Future<List<dynamic>> getRequestsByClassroom(String classroomId) async {
    return await _client
        .from(AppDatabase.tableMedicationRequests)
        .select('*, ${AppDatabase.tableStudents}(*)')
        .eq('${AppDatabase.tableStudents}.${AppDatabase.colClassroomId}', classroomId)
        .order(AppDatabase.colCreatedAt, ascending: false);
  }

  // Phụ huynh: Lấy đơn đã gửi của mình
  Future<List<dynamic>> getRequestsByParent(String parentId) async {
    return await _client
        .from(AppDatabase.tableMedicationRequests)
        .select('*, ${AppDatabase.tableStudents}(*, ${AppDatabase.tableClassrooms}(${AppDatabase.colName}))')
        .eq(AppDatabase.colParentId, parentId)
        .order(AppDatabase.colCreatedAt, ascending: false);
  }

  Future<Map<String, dynamic>> getRequestById(String requestId) async {
    return await _client
        .from(AppDatabase.tableMedicationRequests)
        .select()
        .eq(AppDatabase.colId, requestId)
        .single();
  }

  // Tạo đơn mới
  Future<void> insertRequest(Map<String, dynamic> data) async {
    await _client.from(AppDatabase.tableMedicationRequests).insert(data);
  }

  // Upload file đính kèm (Ảnh đơn thuốc)
  Future<String?> uploadPrescriptionImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'prescriptions/$fileName';
      
      // Chú ý: Cần đảm bảo bucket 'medications' đã được tạo trên Supabase Storage và set Public
      await _client.storage.from('medications').upload(path, imageFile);
      
      return _client.storage.from('medications').getPublicUrl(path);
    } catch (e) {
      rethrow;
    }
  }

  // Cập nhật trạng thái
  Future<void> updateStatus(String id, Map<String, dynamic> data) async {
    await _client.from(AppDatabase.tableMedicationRequests).update(data).eq(AppDatabase.colId, id);
  }
}

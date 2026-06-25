import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/values/app_database.dart';
import '../../../core/services/cloudinary_service.dart';

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
  Future<String?> uploadPrescriptionImage(File imageFile, {required String folder}) async {
    try {
      return await CloudinaryService.to.uploadImage(imageFile, folder: folder);
    } catch (e) {
      rethrow;
    }
  }

  // Cập nhật trạng thái
  Future<void> updateStatus(String id, Map<String, dynamic> data) async {
    await _client.from(AppDatabase.tableMedicationRequests).update(data).eq(AppDatabase.colId, id);
  }
}

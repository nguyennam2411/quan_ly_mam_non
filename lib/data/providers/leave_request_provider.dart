import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/values/app_database.dart';

class LeaveRequestProvider {
  final _client = Supabase.instance.client;

  // Giáo viên: Lấy đơn của lớp
  Future<List<dynamic>> getRequestsByClassroom(String classroomId) async {
    return await _client
        .from(AppDatabase.tableLeaveRequests)
        .select('*, ${AppDatabase.tableStudents}(*)')
        .eq('${AppDatabase.tableStudents}.${AppDatabase.colClassroomId}', classroomId)
        .order(AppDatabase.colCreatedAt, ascending: false);
  }

  // Phụ huynh: Lấy đơn đã gửi của mình
  Future<List<dynamic>> getRequestsByParent(String parentId) async {
    return await _client
        .from(AppDatabase.tableLeaveRequests)
        .select('*, ${AppDatabase.tableStudents}(*, ${AppDatabase.tableClassrooms}(${AppDatabase.colName}))')
        .eq(AppDatabase.colParentId, parentId)
        .order(AppDatabase.colCreatedAt, ascending: false);
  }

  Future<Map<String, dynamic>> getRequestById(String requestId) async {
    return await _client
        .from(AppDatabase.tableLeaveRequests)
        .select()
        .eq(AppDatabase.colId, requestId)
        .single();
  }

  // Tạo đơn mới
  Future<void> insertRequest(Map<String, dynamic> data) async {
    await _client.from(AppDatabase.tableLeaveRequests).insert(data);
  }

  // Upload file đính kèm
  Future<String?> uploadEvidence(File imageFile) async {
  try {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'proofs/$fileName';
    
    // Upload vào bucket 'leave_proofs'
    await _client.storage.from('leave_proofs').upload(path, imageFile);
    
    // Lấy link công khai
    return _client.storage.from('leave_proofs').getPublicUrl(path);
  } catch (e) {
    rethrow;
  }
}

  // Cập nhật trạng thái (Duyệt/Từ chối)
  Future<void> updateStatus(String id, Map<String, dynamic> data) async {
    await _client.from(AppDatabase.tableLeaveRequests).update(data).eq(AppDatabase.colId, id);
  }

  Future<void> deleteAutoExcusedAttendanceForRange({
    required String studentId,
    required String startDate,
    required String endDate,
  }) async {
    await _client
        .from(AppDatabase.tableAttendance)
        .delete()
        .eq(AppDatabase.colStudentId, studentId)
        .eq(AppDatabase.colStatus, AppDatabase.statusAbsentExcused)
        .gte(AppDatabase.colDate, startDate)
        .lte(AppDatabase.colDate, endDate)
        // Chi xoa ban ghi do he thong/trigger tao, giu nguyen diem danh manual cua giao vien.
        .or('${AppDatabase.colMethod}.is.null,${AppDatabase.colMethod}.neq.${AppDatabase.methodManual}');
  }
}

import 'dart:io';
import '../../../core/utils/image_helper.dart';
import '../models/leave_request_model.dart';
import '../providers/leave_request_provider.dart';
import '../../../core/values/app_database.dart';

class LeaveRequestRepository {
  final LeaveRequestProvider _provider = LeaveRequestProvider();

  // GV: Lấy danh sách đơn cần duyệt
  Future<List<LeaveRequestModel>> getTeacherLeaveRequests(String classroomId) async {
    final response = await _provider.getRequestsByClassroom(classroomId);
    return (response as List).map((e) => LeaveRequestModel.fromJson(e)).toList();
  }

  // PH: Lấy lịch sử đơn của mình
  Future<List<LeaveRequestModel>> getRequestsByParent(String parentId) async {
    final response = await _provider.getRequestsByParent(parentId);
    return (response as List).map((e) => LeaveRequestModel.fromJson(e)).toList();
  }

  // PH: Gửi đơn xin nghỉ
  Future<void> submitLeaveRequest(LeaveRequestModel request) async {
    await _provider.insertRequest(request.toJson());
  }

  // PH: Rút đơn (Chuyển sang CANCELLED)
  Future<void> cancelRequest(String requestId, String reason) async {
    final request = await _getRequestById(requestId);
    final data = {
      AppDatabase.colStatus: AppDatabase.cancelled,
      // lý do hủy
      AppDatabase.colCancelReason: reason, 
      //AppDatabase.colUpdatedAt: DateTime.now().toIso8601String(),
    };
    await _provider.updateStatus(requestId, data);
    await _revertAutoExcusedAttendance(request);
  }

  // GV: Duyệt hoặc Từ chối đơn
  Future<void> updateRequestStatus(String requestId, String status, String teacherId, {String? reason}) async {
    final request = await _getRequestById(requestId);
    final data = {
      AppDatabase.colStatus: status,
      AppDatabase.colApprovedBy: teacherId,
      AppDatabase.colApprovedAt: DateTime.now().toUtc().toIso8601String(),
      if (reason != null) AppDatabase.colCancelReason: reason,
    };
    await _provider.updateStatus(requestId, data);

    if (status == AppDatabase.rejected || status == AppDatabase.cancelled) {
      await _revertAutoExcusedAttendance(request);
    }
  }

  Future<void> submitLeaveRequestWithImages(LeaveRequestModel request, List<File> imageFiles) async {
    List<String> imageUrls = [];

    // 1. Nếu có ảnh, nén ảnh và upload để lấy URL
    if (imageFiles.isNotEmpty) {
      for (var imageFile in imageFiles) {
        // Sử dụng Helper dùng chung để nén ảnh
        final compressedFile = await ImageHelper.compressImage(imageFile);
        
        // Upload file đã nén
        final imageUrl = await _provider.uploadEvidence(compressedFile);
        
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
        
        // Nếu là file tạm (khác file gốc), hãy xóa đi để tiết kiệm bộ nhớ máy
        if (compressedFile.path != imageFile.path) {
          await ImageHelper.deleteTempFile(compressedFile);
        }
      }
    }

    // 2. Tạo bản copy của model có kèm URL ảnh
    final finalRequest = LeaveRequestModel(
      studentId: request.studentId,
      parentId: request.parentId,
      reason: request.reason,
      status: AppDatabase.pending,
      startDate: request.startDate,
      endDate: request.endDate,
      images: imageUrls, // Gán mảng URL vào đây
    );

    // 3. Lưu toàn bộ đơn vào Database
    await _provider.insertRequest(finalRequest.toJson());
  }

  Future<LeaveRequestModel> _getRequestById(String requestId) async {
    final response = await _provider.getRequestById(requestId);
    return LeaveRequestModel.fromJson(response);
  }

  Future<void> _revertAutoExcusedAttendance(LeaveRequestModel request) async {
    await _provider.deleteAutoExcusedAttendanceForRange(
      studentId: request.studentId,
      startDate: request.startDate,
      endDate: request.endDate,
    );
  }
}

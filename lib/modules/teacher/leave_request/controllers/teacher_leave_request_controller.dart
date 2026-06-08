import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/models/leave_request_model.dart';
import '../../../../data/repositories/leave_request_repository.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/utils/app_error_message.dart';

class TeacherLeaveRequestController extends GetxController {
  final LeaveRequestRepository repository;
  TeacherLeaveRequestController({required this.repository});

  // --- States ---
  var isLoading = false.obs;
  var allRequests = <LeaveRequestModel>[].obs;
  RealtimeChannel? _realtimeChannel;
  
  // Lọc và Tìm kiếm
  var searchQuery = ''.obs;
  var selectedStatus = AppStrings.leaveStatusAll.obs;
  var isDescending = true.obs; // Mới nhất lên đầu

  void toggleSortOrder() {
    isDescending.value = !isDescending.value;
  }

  // Getter xử lý Lọc + Tìm kiếm + Sắp xếp
  List<LeaveRequestModel> get filteredRequests {
    final list = allRequests.where((request) {
      // 1. Lọc theo trạng thái
      bool matchStatus = true;
      if (selectedStatus.value != AppStrings.leaveStatusAll) {
        String dbStatus = _mapLabelToStatus(selectedStatus.value);
        matchStatus = request.status == dbStatus;
      }

      // 2. Tìm kiếm theo tên học sinh
      bool matchSearch = true;
      if (searchQuery.value.isNotEmpty) {
        matchSearch = (request.student?.name ?? '')
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase());
      }

      return matchStatus && matchSearch;
    }).toList();

    // 3. Sắp xếp
    list.sort((a, b) {
      final dateA = a.createdAt ?? DateTime.now();
      final dateB = b.createdAt ?? DateTime.now();
      return isDescending.value 
          ? dateB.compareTo(dateA) 
          : dateA.compareTo(dateB);
    });

    return list;
  }

  Map<String, int> get statusCounts {
    return {
      AppStrings.leaveStatusAll: allRequests.length,
      AppStrings.leaveStatusPending: allRequests.where((r) => r.status == AppDatabase.pending).length,
      AppStrings.leaveStatusApproved: allRequests.where((r) => r.status == AppDatabase.approved).length,
      AppStrings.leaveStatusRejected: allRequests.where((r) => r.status == AppDatabase.rejected).length,
      AppStrings.leaveStatusCancelled: allRequests.where((r) => r.status == AppDatabase.cancelled).length,
    };
  }

  String _mapLabelToStatus(String label) {
    switch (label) {
      case AppStrings.leaveStatusPending:
        return AppDatabase.pending;
      case AppStrings.leaveStatusApproved:
        return AppDatabase.approved;
      case AppStrings.leaveStatusRejected:
        return AppDatabase.rejected;
      case AppStrings.leaveStatusCancelled:
        return AppDatabase.cancelled;
      default:
        return '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
    _setupRealtimeListener();
  }

  Future<void> fetchRequests() async {
    isLoading.value = true;
    try {
      final classroomId = AuthService.to.classroomId.value;
      if (classroomId.isEmpty) {
        // Có thể load classroomId từ profile nếu cần
      }
      final result = await repository.getTeacherLeaveRequests(classroomId);
      allRequests.assignAll(result);
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isLoading.value = false;
    }
  }

  // Hàm xử lý Duyệt/Từ chối
  Future<void> updateStatus(String requestId, String newStatus, {String? reason}) async {
    isLoading.value = true;
    try {
      final teacherId = AuthService.to.currentUser.value!.id;
      await repository.updateRequestStatus(requestId, newStatus, teacherId, reason: reason);
      
      AppDialogs.success(message: AppStrings.leaveRequestUpdateStatusSuccess);
      await fetchRequests(); // Refresh lại danh sách
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isLoading.value = false;
    }
  }

  void _setupRealtimeListener() {
    final classroomId = AuthService.to.classroomId.value;
    if (classroomId.isEmpty) return;

    _realtimeChannel = Supabase.instance.client
        .channel('teacher_leave_requests_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppDatabase.tableLeaveRequests,
          callback: (payload) async {
            final newRecord = payload.newRecord;
            final oldRecord = payload.oldRecord;
            final studentId = newRecord[AppDatabase.colStudentId] ?? oldRecord[AppDatabase.colStudentId];
            
            if (studentId != null) {
              try {
                // Kiểm tra nhanh xem học sinh của đơn này có thuộc lớp của giáo viên hiện tại không
                final studentClassroomId = await repository.getStudentClassroomId(studentId);

                if (studentClassroomId == classroomId) {
                  debugPrint('Realtime: Leave request update detected for student $studentId in classroom $classroomId. Refreshing...');
                  await fetchRequests();
                }
              } catch (e) {
                debugPrint('Realtime Error verifying student classroom: $e');
              }
            }
          },
        );
    
    _realtimeChannel?.subscribe();
  }

  @override
  void onClose() {
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
    }
    super.onClose();
  }
}
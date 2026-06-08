import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/parent_student_service.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/utils/app_error_message.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../data/models/leave_request_model.dart';
import '../../../../data/repositories/leave_request_repository.dart';

class ParentLeaveRequestController extends GetxController {
  final LeaveRequestRepository repository;
  ParentLeaveRequestController({required this.repository});

  // --- States ---
  var isLoading = false.obs;
  var leaveRequests = <LeaveRequestModel>[].obs;
  RealtimeChannel? _realtimeChannel;
  
  // Lọc và Tìm kiếm
  var searchQuery = ''.obs;
  var selectedStatus = AppStrings.leaveStatusAll.obs;
  var isDescending = true.obs; // Newest first by default

  void toggleSortOrder() {
    isDescending.value = !isDescending.value;
  }

  // Danh sách đã lọc (Áp dụng theo học sinh đang được chọn từ Home/Service)
  List<LeaveRequestModel> get filteredRequests {
    final currentStudent = ParentStudentService.to.selectedStudent.value;
    
    final list = leaveRequests.where((request) {
      // 0. Lọc theo học sinh đang chọn (QUAN TRỌNG)
      if (currentStudent != null && request.studentId != currentStudent.id) {
        return false;
      }

      // 1. Lọc theo trạng thái
      bool matchStatus = true;
      if (selectedStatus.value != AppStrings.leaveStatusAll) {
        String dbStatus = _mapLabelToStatus(selectedStatus.value);
        matchStatus = request.status == dbStatus;
      }

      // 2. Tìm kiếm theo tên (nếu vẫn muốn tìm kiếm trong phạm vi bé đó)
      bool matchSearch = true;
      if (searchQuery.value.isNotEmpty) {
        matchSearch = (request.student?.name ?? '')
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase());
      }

      return matchStatus && matchSearch;
    }).toList();

    // Sắp xếp theo ngày gửi
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
    final currentStudent = ParentStudentService.to.selectedStudent.value;
    final studentRequests = leaveRequests.where((r) {
      if (currentStudent != null && r.studentId != currentStudent.id) {
        return false;
      }
      return true;
    }).toList();

    return {
      AppStrings.leaveStatusAll: studentRequests.length,
      AppStrings.leaveStatusPending: studentRequests.where((r) => r.status == AppDatabase.pending).length,
      AppStrings.leaveStatusApproved: studentRequests.where((r) => r.status == AppDatabase.approved).length,
      AppStrings.leaveStatusRejected: studentRequests.where((r) => r.status == AppDatabase.rejected).length,
      AppStrings.leaveStatusCancelled: studentRequests.where((r) => r.status == AppDatabase.cancelled).length,
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

  // States cho Form tạo đơn
  final formKey = GlobalKey<FormState>();
  final autovalidateMode = AutovalidateMode.disabled.obs;
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  final reasonController = TextEditingController();
  var selectedImages = <File>[].obs;
  var hasChanges = false.obs;
  final List<Worker> _workers = [];

  @override
  void onInit() {
    super.onInit();
    fetchMyLeaveRequests();
    _setupRealtimeListener();
    
    // Lắng nghe thay đổi học sinh để làm mới hoặc cập nhật UI nếu cần
    _workers.add(ever(ParentStudentService.to.selectedStudent, (_) {
      fetchMyLeaveRequests();
    }));

    // Theo dõi thay đổi trong Form để cảnh báo thoát
    reasonController.addListener(() {
      if (reasonController.text.isNotEmpty) {
        hasChanges.value = true;
      }
    });

    // Theo dõi các trường Rx khác
    _workers.add(ever(startDate, (_) => hasChanges.value = true));
    _workers.add(ever(endDate, (_) => hasChanges.value = true));
    _workers.add(ever(selectedImages, (_) => hasChanges.value = true));
  }

  void resetForm() {
    startDate.value = null;
    endDate.value = null;
    reasonController.clear();
    selectedImages.clear();
    hasChanges.value = false;
    autovalidateMode.value = AutovalidateMode.disabled;
    formKey.currentState?.reset();
  }

  // 1. Lấy danh sách đơn
  Future<void> fetchMyLeaveRequests() async {
    isLoading.value = true;
    try {
      final parentId = AuthService.to.currentUser.value?.id;
      if (parentId != null) {
        final results = await repository.getRequestsByParent(parentId);
        leaveRequests.assignAll(results);
      }
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isLoading.value = false;
    }
  }


  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  // 3. Gửi đơn
  Future<void> submitRequest() async {
    final currentStudent = ParentStudentService.to.selectedStudent.value;
    if (currentStudent == null) {
      AppDialogs.error(message: AppStrings.errorStudentNotFound);
      return;
    }

    if (!formKey.currentState!.validate()) {
      autovalidateMode.value = AutovalidateMode.onUserInteraction;
      return;
    }

    // Kiểm tra không cho phép chọn ngày quá khứ
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (startDate.value != null && startDate.value!.isBefore(today)) {
      AppDialogs.warning(message: AppStrings.leaveRequestPastDateWarning);
      return;
    }

    isLoading.value = true;
    try {
      final request = LeaveRequestModel(
        studentId: currentStudent.id,
        parentId: AuthService.to.currentUser.value!.id,
        reason: reasonController.text,
        status: AppDatabase.pending,
        startDate: startDate.value!.toIso8601String().split('T')[0],
        endDate: endDate.value!.toIso8601String().split('T')[0],
      );

      await repository.submitLeaveRequestWithImages(request, selectedImages.toList());
      
      Get.back();
      AppDialogs.success(message: AppStrings.leaveRequestSubmitSuccess);
      
      resetForm(); // Reset form sau khi gửi thành công
      fetchMyLeaveRequests();
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isLoading.value = false;
    }
  }

  // 4. Hủy đơn (Cancelled)
  Future<void> cancelRequest(String requestId, String reason) async {
    try {
      await repository.cancelRequest(requestId, reason);
      fetchMyLeaveRequests();
      AppDialogs.success(message: AppStrings.leaveRequestCancelSuccess);
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    }
  }

  void _setupRealtimeListener() {
    final parentId = AuthService.to.currentUser.value?.id;
    if (parentId == null) return;

    _realtimeChannel = Supabase.instance.client
        .channel('parent_leave_requests_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppDatabase.tableLeaveRequests,
          callback: (payload) {
            final newRecord = payload.newRecord;
            final oldRecord = payload.oldRecord;
            final recordParentId = newRecord[AppDatabase.colParentId] ?? oldRecord[AppDatabase.colParentId];
            if (recordParentId == parentId) {
              debugPrint('Realtime: Leave request update detected for parent $parentId. Refreshing...');
              fetchMyLeaveRequests();
            }
          },
        );
    
    _realtimeChannel?.subscribe();
  }

  @override
  void onClose() {
    for (var worker in _workers) {
      worker.dispose();
    }
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
    }
    reasonController.dispose();
    super.onClose();
  }
}
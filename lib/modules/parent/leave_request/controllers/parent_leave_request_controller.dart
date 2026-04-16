import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/parent_student_service.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../data/models/leave_request_model.dart';
import '../../../../data/repositories/leave_request_repository.dart';

class ParentLeaveRequestController extends GetxController {
  final LeaveRequestRepository repository = Get.find();

  // --- States ---
  var isLoading = false.obs;
  var leaveRequests = <LeaveRequestModel>[].obs;
  
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
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  final reasonController = TextEditingController();
  var selectedImage = Rxn<File>();
  var hasChanges = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyLeaveRequests();
    
    // Lắng nghe thay đổi học sinh để làm mới hoặc cập nhật UI nếu cần
    ever(ParentStudentService.to.selectedStudent, (_) {
      fetchMyLeaveRequests();
    });

    // Theo dõi thay đổi trong Form để cảnh báo thoát
    reasonController.addListener(() {
      if (reasonController.text.isNotEmpty) {
        hasChanges.value = true;
      }
    });

    // Theo dõi các trường Rx khác
    ever(startDate, (_) => hasChanges.value = true);
    ever(endDate, (_) => hasChanges.value = true);
    ever(selectedImage, (_) => hasChanges.value = true);
  }

  void resetForm() {
    startDate.value = null;
    endDate.value = null;
    reasonController.clear();
    selectedImage.value = null;
    hasChanges.value = false;
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
      Get.snackbar('Lỗi', 'Không thể tải lịch sử đơn: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Chọn ảnh minh chứng
  Future<void> pickImage() async {
    final file = await ImageHelper.pickImage(ImageSource.gallery, crop: true);
    if (file != null) {
      selectedImage.value = file;
    }
  }

  // 3. Gửi đơn
  Future<void> submitRequest() async {
    final currentStudent = ParentStudentService.to.selectedStudent.value;
    if (currentStudent == null) {
      Get.snackbar('Lỗi', 'Không xác định được học sinh học sinh');
      return;
    }

    if (startDate.value == null || endDate.value == null || reasonController.text.isEmpty) {
      Get.snackbar('Thông báo', 'Vui lòng điền đầy đủ thông tin');
      return;
    }

    // Kiểm tra không cho phép chọn ngày quá khứ
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (startDate.value!.isBefore(today)) {
      Get.snackbar('Thông báo', 'Không thể gửi đơn xin nghỉ cho các ngày trong quá khứ');
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

      await repository.submitLeaveRequestWithImage(request, selectedImage.value);
      
      Get.back();
      Get.snackbar('Thành công', 'Đơn xin nghỉ đã được gửi và đang chờ duyệt',
          backgroundColor: Colors.green, colorText: Colors.white);
      
      resetForm(); // Reset form sau khi gửi thành công
      fetchMyLeaveRequests();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể gửi đơn: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 4. Hủy đơn (Cancelled)
  Future<void> cancelRequest(String requestId, String reason) async {
    try {
      await repository.cancelRequest(requestId, reason);
      fetchMyLeaveRequests();
      Get.snackbar('Thông báo', 'Đã hủy đơn thành công');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể hủy đơn: $e');
    }
  }
}
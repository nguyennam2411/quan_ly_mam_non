import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../data/models/medication_request_model.dart';
import '../../../../data/repositories/medication_repository.dart';

class TeacherMedicationRequestController extends GetxController {
  final MedicationRepository repository;
  TeacherMedicationRequestController({required this.repository});

  var isLoading = false.obs;
  var allRequests = <MedicationRequestModel>[].obs;
  
  var searchQuery = ''.obs;
  var selectedStatus = AppStrings.leaveStatusAll.obs; 
  var isDescending = true.obs; 

  void toggleSortOrder() {
    isDescending.value = !isDescending.value;
  }

  List<MedicationRequestModel> get filteredRequests {
    final list = allRequests.where((request) {
      // Ải 1: Chặn ngay lập tức nếu đơn thuốc này không thuộc sinh viên lớp này (student null do khác lớp)
      if (request.student == null) return false;

      // Ải 2: Bỏ qua các đơn bị hủy bởi phụ huynh
      if (request.status == AppDatabase.cancelled) return false;

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

  String _mapLabelToStatus(String label) {
    if (label == AppStrings.medicationStatusPending) return AppDatabase.pending;
    if (label == AppStrings.medicationStatusCompleted) return AppDatabase.completed;
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    isLoading.value = true;
    try {
      final classroomId = AuthService.to.classroomId.value;
      if (classroomId.isEmpty) {
        Get.snackbar('Lỗi', 'Chưa được gán lớp học!');
        return;
      }
      final result = await repository.getTeacherMedicationRequests(classroomId);
      allRequests.assignAll(result);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách dặn thuốc: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Cập nhật trạng thái thành Đã Cho Uống
  Future<void> markAsCompleted(String requestId) async {
    isLoading.value = true;
    try {
      final teacherId = AuthService.to.currentUser.value!.id;
      
      await repository.updateRequestStatus(requestId, AppDatabase.completed, teacherId);
      
      Get.snackbar('Thành công', 'Đã ghi nhận Đã Cho Uống', backgroundColor: Colors.green, colorText: Colors.white);
      await fetchRequests();
    } catch (e) {
      Get.snackbar('Lỗi', 'Thao tác thất bại: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

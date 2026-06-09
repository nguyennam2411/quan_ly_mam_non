import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../data/models/medication_request_model.dart';
import '../../../../data/repositories/medication_repository.dart';
import '../../../../data/repositories/notification_repository.dart';

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

  Map<String, int> get statusCounts {
    final relevantRequests = allRequests.where((r) {
      if (r.student == null) return false;
      if (r.status == AppDatabase.cancelled) return false;
      return true;
    }).toList();

    int pendingCount = relevantRequests.where((r) => r.status == AppDatabase.pending).length;
    int completedCount = relevantRequests.where((r) => r.status == AppDatabase.completed).length;
    int medicalCount = relevantRequests.where((r) => r.status == AppDatabase.rejected).length;

    return {
      AppStrings.leaveStatusAll: relevantRequests.length,
      AppStrings.medicationStatusPending: pendingCount,
      AppStrings.medicationStatusCompleted: completedCount,
      AppStrings.medicationStatusMedical: medicalCount,
    };
  }

  String _mapLabelToStatus(String label) {
    if (label == AppStrings.medicationStatusPending) return AppDatabase.pending;
    if (label == AppStrings.medicationStatusCompleted) return AppDatabase.completed;
    if (label == AppStrings.medicationStatusMedical) return AppDatabase.rejected;
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

  // Chuyển xuống Y tế (Dùng trạng thái REJECTED)
  Future<void> transferToMedical(String requestId) async {
    isLoading.value = true;
    try {
      final teacherId = AuthService.to.currentUser.value!.id;
      
      await repository.updateRequestStatus(requestId, AppDatabase.rejected, teacherId);
      
      // Gửi thông báo cho phụ huynh
      try {
        final request = allRequests.firstWhereOrNull((r) => r.id == requestId);
        if (request != null && request.parentId != null) {
          final notifRepo = Get.find<NotificationRepository>();
          await notifRepo.createNotification(
            userId: request.parentId!,
            title: 'Cập nhật Dặn Thuốc',
            content: 'Bé ${request.student?.name ?? 'nhà bạn'} đã được chuyển xuống Phòng Y Tế thay vì uống thuốc trên lớp.',
            type: 'MEDICATION_STATUS',
          );
        }
      } catch (e) {
        debugPrint('Lỗi gửi thông báo: $e');
      }

      Get.snackbar(
        'Đã Chuyển Y Tế', 
        'Đã ngưng đơn thuốc và chuyển bé xuống phòng Y tế.', 
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      await fetchRequests();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái: $e');
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
      
      // Gửi thông báo cho phụ huynh
      try {
        final request = allRequests.firstWhereOrNull((r) => r.id == requestId);
        if (request != null && request.parentId != null) {
          final notifRepo = Get.find<NotificationRepository>();
          await notifRepo.createNotification(
            userId: request.parentId!,
            title: 'Cập nhật Dặn Thuốc',
            content: 'Cô giáo đã cho bé ${request.student?.name ?? 'nhà bạn'} uống thuốc thành công.',
            type: 'MEDICATION_STATUS',
          );
        }
      } catch (e) {
        debugPrint('Lỗi gửi thông báo: $e');
      }

      Get.snackbar('Thành công', 'Đã ghi nhận Đã Cho Uống', backgroundColor: Colors.green, colorText: Colors.white);
      await fetchRequests();
    } catch (e) {
      Get.snackbar('Lỗi', 'Thao tác thất bại: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

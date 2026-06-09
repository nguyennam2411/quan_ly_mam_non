import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/parent_student_service.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../data/models/medication_request_model.dart';
import '../../../../data/repositories/medication_repository.dart';
import '../../../../data/repositories/notification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ParentMedicationRequestController extends GetxController {
  final MedicationRepository repository = Get.find();

  var isLoading = false.obs;
  var medicationRequests = <MedicationRequestModel>[].obs;
  
  var searchQuery = ''.obs;
  var selectedStatus = AppStrings.leaveStatusAll.obs; 
  var isDescending = true.obs; 

  void toggleSortOrder() {
    isDescending.value = !isDescending.value;
  }

  List<MedicationRequestModel> get filteredRequests {
    final currentStudent = ParentStudentService.to.selectedStudent.value;
    
    final list = medicationRequests.where((request) {
      if (currentStudent != null && request.studentId != currentStudent.id) {
        return false;
      }
      bool matchStatus = true;
      if (selectedStatus.value != AppStrings.leaveStatusAll) {
        String dbStatus = _mapLabelToStatus(selectedStatus.value);
        matchStatus = request.status == dbStatus;
      }
      bool matchSearch = true;
      if (searchQuery.value.isNotEmpty) {
        matchSearch = (request.student?.name ?? '')
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase());
      }
      return matchStatus && matchSearch;
    }).toList();

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
    final relevantRequests = medicationRequests.where((r) {
      if (currentStudent != null && r.studentId != currentStudent.id) return false;
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

  var applyDate = Rxn<DateTime>();
  final medicineNameController = TextEditingController();
  final dosageController = TextEditingController();
  var selectedTimes = <String>[].obs;
  final symptomsController = TextEditingController();
  final noteController = TextEditingController();
  var selectedImage = Rxn<File>();
  var hasChanges = false.obs;
  var isAgreedToMedicalPolicy = false.obs;
  var showFeverWarning = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyMedicationRequests();
    
    ever(ParentStudentService.to.selectedStudent, (_) {
      fetchMyMedicationRequests();
    });

    void checkChanges() => hasChanges.value = true;
    void checkFever() {
      final text = symptomsController.text.toLowerCase();
      showFeverWarning.value = text.contains('sốt') || 
                               text.contains('nóng') || 
                               text.contains('38') || 
                               text.contains('39') || 
                               text.contains('40');
    }
    medicineNameController.addListener(checkChanges);
    dosageController.addListener(checkChanges);
    symptomsController.addListener(() {
      checkChanges();
      checkFever();
    });
    noteController.addListener(checkChanges);
    selectedTimes.listen((_) => checkChanges());
    ever(applyDate, (_) => checkChanges());
    ever(selectedImage, (_) => checkChanges());
  }

  void toggleTimeSelection(String time) {
    if (selectedTimes.contains(time)) {
      selectedTimes.remove(time);
    } else {
      selectedTimes.add(time);
    }
  }

  void resetForm() {
    applyDate.value = null;
    medicineNameController.clear();
    dosageController.clear();
    selectedTimes.clear();
    symptomsController.clear();
    noteController.clear();
    selectedImage.value = null;
    hasChanges.value = false;
    isAgreedToMedicalPolicy.value = false;
    showFeverWarning.value = false;
  }

  Future<void> fetchMyMedicationRequests() async {
    isLoading.value = true;
    try {
      final parentId = AuthService.to.currentUser.value?.id;
      if (parentId != null) {
        final results = await repository.getRequestsByParent(parentId);
        medicationRequests.assignAll(results);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải lịch sử đơn dặn thuốc: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final file = await ImageHelper.pickImage(source, crop: true);
    if (file != null) {
      selectedImage.value = file;
    }
  }

  Future<void> submitRequest() async {
    final currentStudent = ParentStudentService.to.selectedStudent.value;
    if (currentStudent == null) {
      Get.snackbar('Lỗi', 'Không xác định được học sinh hiện tại');
      return;
    }

    if (applyDate.value == null || medicineNameController.text.isEmpty || dosageController.text.isEmpty || selectedTimes.isEmpty) {
      Get.snackbar('Thông báo', 'Vui lòng điền đủ các thông tin bắt buộc');
      return;
    }

    if (!isAgreedToMedicalPolicy.value) {
      Get.snackbar('Thông báo', 'Vui lòng đồng ý với chính sách y tế của nhà trường');
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (applyDate.value?.isBefore(today) == true) {
      Get.snackbar('Thông báo', 'Không thể dặn thuốc cho ngày trong quá khứ');
      return;
    }

    isLoading.value = true;
    try {
      String finalNote = '';
      if (symptomsController.text.trim().isNotEmpty) {
        finalNote += 'Triệu chứng: ${symptomsController.text.trim()}\n';
      }
      if (noteController.text.trim().isNotEmpty) {
        finalNote += 'Ghi chú: ${noteController.text.trim()}';
      }

      final request = MedicationRequestModel(
        studentId: currentStudent.id,
        parentId: AuthService.to.currentUser.value!.id,
        medicineName: medicineNameController.text.trim(),
        dosage: dosageController.text.trim(),
        time: selectedTimes.join(', '),
        note: finalNote.isEmpty ? null : finalNote.trim(),
        date: applyDate.value!.toIso8601String().split('T')[0],
        status: AppDatabase.pending,
      );

      await repository.submitRequestWithImage(request, selectedImage.value);
      
      // Gửi thông báo cho giáo viên
      try {
        if (currentStudent.classroomId != null) {
          final classResponse = await Supabase.instance.client
              .from(AppDatabase.tableClassrooms)
              .select(AppDatabase.colTeacherId)
              .eq(AppDatabase.colId, currentStudent.classroomId!)
              .single();
          final teacherId = classResponse[AppDatabase.colTeacherId] as String?;
          if (teacherId != null) {
            final notifRepo = Get.find<NotificationRepository>();
            await notifRepo.createNotification(
              userId: teacherId,
              title: 'Dặn thuốc mới',
              content: 'Phụ huynh bé ${currentStudent.name} vừa gửi đơn dặn thuốc mới.',
              type: 'MEDICATION_REQUEST',
            );
          }
        }
      } catch (e) {
        debugPrint('Không thể gửi thông báo cho giáo viên: $e');
      }

      Get.back();
      Get.snackbar('Thành công', 'Đơn dặn thuốc đã được gửi thành công', backgroundColor: Colors.green, colorText: Colors.white);
      
      resetForm();
      fetchMyMedicationRequests();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể gửi đơn dặn thuốc: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelRequest(String requestId, String reason) async {
    try {
      await repository.cancelRequest(requestId, reason);
      fetchMyMedicationRequests();
      Get.snackbar('Thông báo', 'Đã lưu hủy đơn dặn thuốc thành công');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể hủy đơn dặn thuốc: $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/talent_class_model.dart';
import '../../../../data/repositories/talent_repository.dart';
import '../../../../core/values/app_database.dart';

class TeacherTalentController extends GetxController {
  final TalentRepository _repository = TalentRepository();

  final RxList<TalentClassModel> talentClasses = <TalentClassModel>[].obs;
  final RxBool isLoading = true.obs;
  
  final Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);
  
  final RxList<int> selectedDays = <int>[].obs;
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);
  
  final RxString selectedSubject = 'Vẽ sáng tạo'.obs;
  final List<String> availableSubjects = [
    'Vẽ sáng tạo',
    'Múa cơ bản',
    'Bóng đá',
    'Võ thuật (Taekwondo)',
    'Cờ vua',
    'Đàn Piano',
    'Tiếng Anh tăng cường',
    'Kỹ năng sống'
  ];

  @override
  void onInit() {
    super.onInit();
    fetchTalentClasses();
  }

  Future<void> fetchTalentClasses() async {
    try {
      isLoading.value = true;
      // In reality, this should fetch classes assigned to the current teacher,
      // but for now we fetch all to keep it simple, or repository handles it.
      final classes = await _repository.getAllTalentClasses();
      talentClasses.assignAll(classes);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách lớp năng khiếu');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createClass(TalentClassModel newClass) async {
    try {
      isLoading.value = true;
      await _repository.createTalentClass(newClass);
      Get.snackbar('Thành công', 'Đã tạo lớp năng khiếu mới!');
      await fetchTalentClasses(); // Refresh list
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tạo lớp: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickDate(Rx<DateTime?> targetDate) async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: targetDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay.fromDateTime(targetDate.value ?? DateTime.now()),
      );
      if (time != null) {
        targetDate.value = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
      }
    }
  }

  void toggleDay(int day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
    selectedDays.sort();
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: Get.context!,
      initialTime: selectedTime.value ?? const TimeOfDay(hour: 17, minute: 0),
    );
    if (time != null) {
      selectedTime.value = time;
    }
  }

  Future<void> toggleClassStatus(TalentClassModel talentClass) async {
    try {
      final newStatus = talentClass.status == AppDatabase.statusActive ? 'INACTIVE' : AppDatabase.statusActive;
      await _repository.updateTalentClass(talentClass.id!, {'status': newStatus});
      fetchTalentClasses();
      Get.snackbar('Thành công', 'Đã cập nhật trạng thái lớp');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái: $e');
    }
  }

  Future<void> updateClassDetails(String classId, int fee, String description, String schedule, String name) async {
    try {
      await _repository.updateTalentClass(classId, {
        'name': name,
        'fee_per_month': fee,
        'description': description,
        'schedule_info': schedule,
      });
      fetchTalentClasses();
      Get.snackbar('Thành công', 'Đã cập nhật thông tin lớp học');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật thông tin: $e');
    }
  }
}

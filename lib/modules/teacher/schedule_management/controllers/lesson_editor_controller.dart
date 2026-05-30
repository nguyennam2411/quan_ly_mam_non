import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/values/app_media_folders.dart';
import '../../../../data/repositories/lesson_repository.dart';
import '../../../../data/models/lesson_model.dart';
import '../../../../data/models/schedule_model.dart';
import '../../../../data/providers/schedule_provider.dart';

class LessonEditorController extends GetxController {
  final LessonRepository _repository;
  LessonEditorController({required LessonRepository repository}) : _repository = repository;

  final titleController = TextEditingController();
  final objectivesController = TextEditingController();
  final contentController = TextEditingController();
  final youtubeController = TextEditingController();
  
  final RxList<dynamic> selectedImages = <dynamic>[].obs;
  final RxString status = AppDatabase.statusDraft.obs;
  final RxBool isSaving = false.obs;
  
  final RxList<ScheduleModel> availableSchedules = <ScheduleModel>[].obs;
  final Rx<ScheduleModel?> selectedSchedule = Rx<ScheduleModel?>(null);
  
  String? _existingLessonId;
  DateTime? _currentDate;
  
  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      final lesson = Get.arguments['lesson'] as LessonModel?;
      final schedule = Get.arguments['schedule'] as ScheduleModel?;
      _currentDate = Get.arguments['date'] as DateTime?;
      
      initEditor(lesson, schedule);
      if (_currentDate != null) {
        fetchAvailableSchedules(_currentDate!);
      }
    }
  }

  // Lấy danh sách các khung giờ "học" của ngày đó
  Future<void> fetchAvailableSchedules(DateTime date) async {
    try {
      final classroomId = AuthService.to.classroomId.value;
      if (classroomId.isEmpty) return;

      final dayOfWeek = date.weekday + 1;
      final scheduleProvider = Get.find<ScheduleProvider>();
      final data = await scheduleProvider.getByDay(classroomId, dayOfWeek);
      
      final slots = data
          .map((e) => ScheduleModel.fromJson(e))
          .where((s) => s.isLessonSlot) // Chỉ lấy các khung giờ cho phép dạy
          .toList();
          
      availableSchedules.assignAll(slots);
      
      // Tự động chọn khung giờ phù hợp
      if (selectedSchedule.value == null && slots.isNotEmpty) {
        final lesson = Get.arguments['lesson'] as LessonModel?;
        final passedSchedule = Get.arguments['schedule'] as ScheduleModel?;
        
        // Ưu tiên 1: Theo schedule được truyền sang trực tiếp
        if (passedSchedule != null) {
          selectedSchedule.value = slots.firstWhereOrNull((s) => s.id == passedSchedule.id);
        } 
        // Ưu tiên 2: Theo scheduleId lưu trong bài học
        else if (lesson?.scheduleId != null) {
          selectedSchedule.value = slots.firstWhereOrNull((s) => s.id == lesson!.scheduleId);
        }
      }
    } catch (e) {
      debugPrint('Error fetching schedules: $e');
    }
  }

  // Khởi tạo trình soạn thảo
  void initEditor(LessonModel? lesson, ScheduleModel? schedule) {
    // Nếu có truyền schedule sang trực tiếp thì dùng luôn
    if (schedule != null) {
      selectedSchedule.value = schedule;
    }
    
    if (lesson != null) {
      _existingLessonId = lesson.id;
      // Nếu chưa có schedule nhưng lesson có scheduleId, nó sẽ được set trong fetchAvailableSchedules
      titleController.text = lesson.title;
      objectivesController.text = lesson.objectives ?? '';
      contentController.text = lesson.content ?? '';
      youtubeController.text = lesson.youtubeUrl ?? '';
      selectedImages.assignAll(lesson.images);
      status.value = lesson.status;
    } else {
      _existingLessonId = null;
      _clearForm();
    }
  }

  void _clearForm() {
    titleController.clear();
    objectivesController.clear();
    contentController.clear();
    youtubeController.clear();
    selectedImages.clear();
    status.value = AppDatabase.statusDraft;
  }

  // --- LOGIC LƯU BÀI HỌC ---
  Future<void> saveLesson(DateTime date) async {
    if (titleController.text.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập tiêu đề bài học');
      return;
    }

    final classroomId = AuthService.to.classroomId.value;
    if (classroomId.isEmpty) return;

    try {
      isSaving.value = true;

      // 1. Upload ảnh mới (nếu có)
      final List<String> imageUrls = await _uploadImages(classroomId, date);

      final lesson = LessonModel(
        id: _existingLessonId,
        classroomId: classroomId,
        scheduleId: selectedSchedule.value?.id,
        title: titleController.text.trim(),
        objectives: objectivesController.text.trim(),
        content: contentController.text.trim(),
        date: date,
        images: imageUrls,
        youtubeUrl: youtubeController.text.trim(),
        status: status.value,
      );

      // 3. Lưu vào database
      await _repository.saveLesson(lesson);
      
      Get.back(result: true);
      Get.snackbar('Thành công', 'Đã lưu nội dung bài học');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể lưu bài học: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // Logic upload ảnh lên Cloudinary
  Future<List<String>> _uploadImages(String classroomId, DateTime date) async {
    final List<String> finalUrls = [];
    
    // Thư mục lưu trữ trên Cloudinary tương ứng với bài học
    final uploadFolder = AppMediaFolders.lesson(
      classroomId: classroomId,
      date: date,
      scheduleId: selectedSchedule.value?.id,
    );

    for (var item in selectedImages) {
      if (item is String) {
        finalUrls.add(item);
      } else if (item is File) {
        final imageUrl = await CloudinaryService.to.uploadImage(item, folder: uploadFolder);
        if (imageUrl != null) {
          finalUrls.add(imageUrl);
        }
      }
    }
    return finalUrls;
  }

  void addImage(File file) => selectedImages.add(file);
  void removeImage(int index) => selectedImages.removeAt(index);

  @override
  void onClose() {
    titleController.dispose();
    objectivesController.dispose();
    contentController.dispose();
    youtubeController.dispose();
    super.onClose();
  }
}

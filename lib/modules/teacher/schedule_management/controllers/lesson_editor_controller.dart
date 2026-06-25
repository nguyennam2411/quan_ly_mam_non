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
import '../../../../core/utils/dialog.dart';
import '../../../../core/utils/app_error_message.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../core/values/app_strings.dart';

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
  final formKey = GlobalKey<FormState>();
  final autovalidateMode = AutovalidateMode.disabled.obs;
  
  final RxList<ScheduleModel> availableSchedules = <ScheduleModel>[].obs;
  final Rx<ScheduleModel?> selectedSchedule = Rx<ScheduleModel?>(null);
  
  String? _existingLessonId;
  DateTime? _currentDate;

  // Trạng thái theo dõi thay đổi
  final RxBool hasChanges = false.obs;
  final List<Worker> _workers = [];
  String _initialTitle = '';
  String _initialObjectives = '';
  String _initialContent = '';
  String _initialYoutube = '';
  String _initialStatus = AppDatabase.statusDraft;
  int _initialImagesCount = 0;

  void checkChanges() {
    final titleChanged = titleController.text != _initialTitle;
    final objectivesChanged = objectivesController.text != _initialObjectives;
    final contentChanged = contentController.text != _initialContent;
    final youtubeChanged = youtubeController.text != _initialYoutube;
    final statusChanged = status.value != _initialStatus;
    final imagesChanged = selectedImages.length != _initialImagesCount;

    hasChanges.value = titleChanged ||
        objectivesChanged ||
        contentChanged ||
        youtubeChanged ||
        statusChanged ||
        imagesChanged;
  }
  
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

    // Đăng ký lắng nghe thay đổi
    titleController.addListener(checkChanges);
    objectivesController.addListener(checkChanges);
    contentController.addListener(checkChanges);
    youtubeController.addListener(checkChanges);
    
    _workers.add(ever(status, (_) => checkChanges()));
    _workers.add(ever(selectedImages, (_) => checkChanges()));
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
    autovalidateMode.value = AutovalidateMode.disabled;

    // Ghi nhận giá trị ban đầu để đối chiếu
    _initialTitle = titleController.text;
    _initialObjectives = objectivesController.text;
    _initialContent = contentController.text;
    _initialYoutube = youtubeController.text;
    _initialStatus = status.value;
    _initialImagesCount = selectedImages.length;
    hasChanges.value = false;
  }

  void _clearForm() {
    titleController.clear();
    objectivesController.clear();
    contentController.clear();
    youtubeController.clear();
    selectedImages.clear();
    status.value = AppDatabase.statusDraft;
    autovalidateMode.value = AutovalidateMode.disabled;
    formKey.currentState?.reset();
  }

  // --- LOGIC LƯU BÀI HỌC ---
  Future<void> saveLesson(DateTime date) async {
    if (!formKey.currentState!.validate()) {
      autovalidateMode.value = AutovalidateMode.onUserInteraction;
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
      
      hasChanges.value = false;
      Get.back(result: true);
      AppDialogs.success(message: AppStrings.lessonSaveSuccessMessage);
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
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
        // Nén ảnh trước khi tải lên
        final compressedFile = await ImageHelper.compressImage(item);
        
        final imageUrl = await CloudinaryService.to.uploadImage(compressedFile, folder: uploadFolder);
        if (imageUrl != null) {
          finalUrls.add(imageUrl);
        }

        // Xóa file tạm để giải phóng bộ nhớ đệm
        if (compressedFile.path != item.path) {
          await ImageHelper.deleteTempFile(compressedFile);
        }
      }
    }
    return finalUrls;
  }

  void addImage(File file) => selectedImages.add(file);
  void removeImage(int index) => selectedImages.removeAt(index);

  @override
  void onClose() {
    for (var worker in _workers) {
      worker.dispose();
    }
    titleController.dispose();
    objectivesController.dispose();
    contentController.dispose();
    youtubeController.dispose();
    super.onClose();
  }
}

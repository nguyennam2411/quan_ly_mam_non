import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/services/auth_service.dart';
import 'package:quan_ly_mam_non/data/models/activity_comment_model.dart';
import 'package:quan_ly_mam_non/data/models/activity_log_model.dart';
import 'package:quan_ly_mam_non/data/models/student_model.dart';
import 'package:quan_ly_mam_non/data/repositories/activity_log_repository.dart';
import 'package:quan_ly_mam_non/data/repositories/student_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quan_ly_mam_non/global_widgets/comment_bottom_sheet.dart';

class TeacherActivityLogController extends GetxController {
  final ActivityLogRepository repository;
  final StudentRepository studentRepository;

  TeacherActivityLogController({
    required this.repository,
    required this.studentRepository,
  });

  // --- STATE ---
  var logs = <ActivityLogModel>[].obs;
  var students = <StudentModel>[].obs;
  var isLoading = false.obs;
  var isUploading = false.obs;

  // Add Log form state
  var selectedStudents = <String>{}.obs; // Set of student IDs
  var isAllClass = true.obs;
  var selectedTags = <String>{}.obs;
  var contentController = TextEditingController();
  var selectedImages = <File>[].obs;

  final List<String> quickTags = ["Ăn ngoan", "Ngủ tốt", "Học tập tích cực", "Vui vẻ", "Cần cố gắng"];

  String get currentClassId => AuthService.to.classroomId.value;
  String get currentTeacherId => AuthService.to.currentUser.value?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchLogs();
    fetchStudents();
  }

  Future<void> fetchLogs() async {
    if (currentClassId.isEmpty) return;
    isLoading.value = true;
    try {
      final result = await repository.getLogsByClassroom(currentClassId);
      logs.assignAll(result);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải nhật ký: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStudents() async {
    if (currentClassId.isEmpty) return;
    try {
      final result = await studentRepository.getStudentsByClassroom(currentClassId);
      students.assignAll(result);
    } catch (e) {
      print('Error fetching students: $e');
    }
  }

  // --- FORM LOGIC ---

  void toggleStudent(String studentId) {
    if (selectedStudents.contains(studentId)) {
      selectedStudents.remove(studentId);
    } else {
      selectedStudents.add(studentId);
    }
    isAllClass.value = selectedStudents.isEmpty;
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      selectedImages.addAll(images.map((image) => File(image.path)));
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  Future<void> submitLog() async {
    if (contentController.text.trim().isEmpty && selectedTags.isEmpty && selectedImages.isEmpty) {
      Get.snackbar('Cảnh báo', 'Vui lòng nhập nội dung hoặc chọn ảnh');
      return;
    }

    isUploading.value = true;
    try {
      // Chuẩn bị nội dung kèm tag
      String finalContent = contentController.text.trim();
      if (selectedTags.isNotEmpty) {
        final tagsStr = selectedTags.map((t) => "#$t").join(" ");
        finalContent = "$tagsStr\n$finalContent";
      }

      if (isAllClass.value) {
        // Đăng cho cả lớp
        await repository.createActivity(
          teacherId: currentTeacherId,
          classroomId: currentClassId,
          content: finalContent,
          images: selectedImages,
          studentId: null,
        );
      } else {
        // Đăng cho từng bé đã chọn (Tạo mỗi bé 1 bản ghi để phụ huynh dễ theo dõi)
        for (var studentId in selectedStudents) {
          await repository.createActivity(
            teacherId: currentTeacherId,
            classroomId: currentClassId,
            content: finalContent,
            images: selectedImages,
            studentId: studentId,
          );
        }
      }

      Get.back(); // Đóng màn hình add
      Get.snackbar('Thành công', 'Đã đăng nhật ký hoạt động');
      fetchLogs();
      resetForm();
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi đăng: $e');
    } finally {
      isUploading.value = false;
    }
  }

  void resetForm() {
    selectedStudents.clear();
    selectedTags.clear();
    contentController.clear();
    selectedImages.clear();
    isAllClass.value = true;
  }

  // --- INTERACTION LOGIC ---

  Future<void> toggleLike(ActivityLogModel log) async {
    final userId = currentTeacherId;
    if (userId.isEmpty || log.id == null) return;

    // Optimistic update
    final index = logs.indexWhere((e) => e.id == log.id);
    if (index != -1) {
      final newIsLiked = !log.isLiked;
      final newLikeCount = newIsLiked ? log.likeCount + 1 : log.likeCount - 1;

      logs[index] = ActivityLogModel(
        id: log.id,
        classroomId: log.classroomId,
        teacherId: log.teacherId,
        studentId: log.studentId,
        content: log.content,
        createdAt: log.createdAt,
        images: log.images,
        student: log.student,
        likeCount: newLikeCount < 0 ? 0 : newLikeCount,
        commentCount: log.commentCount,
        isLiked: newIsLiked,
      );
    }

    try {
      await repository.toggleLike(log.id!, userId, log.isLiked);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thích bài viết: $e');
      fetchLogs(); // Reload on error
    }
  }

  Future<void> addComment(ActivityLogModel log, String content) async {
    final userId = currentTeacherId;
    if (userId.isEmpty || log.id == null) return;

    try {
      await repository.addComment(log.id!, userId, content);

      // Update count locally
      final index = logs.indexWhere((e) => e.id == log.id);
      if (index != -1) {
        logs[index] = ActivityLogModel(
          id: log.id,
          classroomId: log.classroomId,
          teacherId: log.teacherId,
          studentId: log.studentId,
          content: log.content,
          createdAt: log.createdAt,
          images: log.images,
          student: log.student,
          likeCount: log.likeCount,
          commentCount: log.commentCount + 1,
          isLiked: log.isLiked,
        );
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể gửi bình luận: $e');
    }
  }

  Future<List<ActivityCommentModel>> getComments(String logId) async {
    try {
      return await repository.getComments(logId);
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  void showComments(ActivityLogModel log) {
    Get.bottomSheet(
      CommentBottomSheet(
        activityLog: log,
        onSend: (content) => addComment(log, content),
        getComments: () => getComments(log.id!),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

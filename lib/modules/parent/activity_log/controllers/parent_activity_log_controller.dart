import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/services/parent_student_service.dart';
import 'package:quan_ly_mam_non/data/models/activity_comment_model.dart';
import 'package:quan_ly_mam_non/data/models/activity_log_model.dart';
import 'package:quan_ly_mam_non/data/repositories/activity_log_repository.dart';

class ParentActivityLogController extends GetxController {
  final ActivityLogRepository repository;

  ParentActivityLogController({required this.repository});

  var logs = <ActivityLogModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Tự động tải lại khi đổi bé
    ever(ParentStudentService.to.selectedStudent, (_) => fetchLogs());
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    final student = ParentStudentService.to.selectedStudent.value;
    if (student == null || student.classroomId == null) return;

    isLoading.value = true;
    try {
      final result = await repository.getLogsByStudent(student.id, student.classroomId!);
      logs.assignAll(result);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải nhật ký hoạt động: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike(ActivityLogModel log) async {
    final userId = repository.provider.client.auth.currentUser?.id;
    if (userId == null || log.id == null) return;

    // Optimistic update
    final index = logs.indexOf(log);
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
      // Revert on error
      Get.snackbar('Lỗi', 'Không thể thích bài viết: $e');
      fetchLogs(); // Reload to be safe
    }
  }

  Future<void> addComment(ActivityLogModel log, String content) async {
    final userId = repository.provider.client.auth.currentUser?.id;
    if (userId == null || log.id == null) return;

    try {
      await repository.addComment(log.id!, userId, content);
      
      // Update count locally
      final index = logs.indexOf(log);
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
}

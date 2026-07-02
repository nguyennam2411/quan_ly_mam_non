import 'dart:io';
import '../models/activity_comment_model.dart';
import '../models/activity_log_model.dart';
import '../providers/activity_log_provider.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/values/app_media_folders.dart';

class ActivityLogRepository {
  final ActivityLogProvider provider;

  ActivityLogRepository(this.provider);

  Future<List<ActivityLogModel>> getLogsByClassroom(String classroomId) async {
    final response = await provider.getLogsByClassroom(classroomId);
    return response.map((json) => ActivityLogModel.fromJson(json)).toList();
  }

  Future<List<ActivityLogModel>> getLogsByStudent(String studentId, String classroomId) async {
    final response = await provider.getLogsByStudent(studentId, classroomId);
    return response.map((json) => ActivityLogModel.fromJson(json)).toList();
  }

  Future<void> toggleLike(String activityId, String userId, bool isLiked) async {
    await provider.toggleLike(activityId, userId, isLiked);
  }

  Future<void> addComment(String activityId, String userId, String content) async {
    await provider.addComment(activityId, userId, content);
  }

  Future<List<ActivityCommentModel>> getComments(String activityId) async {
    final response = await provider.getComments(activityId);
    return response.map((json) => ActivityCommentModel.fromJson(json)).toList();
  }

  Future<void> createActivity({
    required String teacherId,
    required String classroomId,
    String? studentId,
    required String content,
    required List<File> images,
  }) async {
    // 1. Tạo bản ghi Log
    final logData = {
      'teacher_id': teacherId,
      'classroom_id': classroomId,
      'content': content,
      'student_id': studentId,
    };
    final logResponse = await provider.insertLog(logData);
    final String logId = logResponse['id'];

    // 2. Upload tất cả ảnh song song (Future.wait)
    if (images.isNotEmpty) {
      final uploadFolder = AppMediaFolders.activity(classroomId, logId);

      final uploadedUrls = await Future.wait(images.map((image) async {
        final compressedFile = await ImageHelper.compressImage(image);
        final imageUrl = await provider.uploadFile(compressedFile, uploadFolder);
        // Xóa file tạm thời sau khi tải lên để giải phóng bộ nhớ
        if (compressedFile.path != image.path) {
          await ImageHelper.deleteTempFile(compressedFile);
        }
        return imageUrl;
      }));

      final imagesToInsert = uploadedUrls
          .map((url) => {'activity_id': logId, 'image_url': url})
          .toList();

      await provider.insertImages(imagesToInsert);
    }
  }

  Future<void> createActivitiesBatch({
    required String teacherId,
    required String classroomId,
    required String generalContent,
    required List<StudentActivityInput> studentActivities,
  }) async {
    final List<File> imagesToUpload = [];
    final List<int> studentIndicesForImages = [];

    for (int i = 0; i < studentActivities.length; i++) {
      final act = studentActivities[i];
      if (act.image != null) {
        imagesToUpload.add(act.image!);
        studentIndicesForImages.add(i);
      }
    }

    final List<String> uploadedUrls = List.filled(imagesToUpload.length, '');
    if (imagesToUpload.isNotEmpty) {
      await Future.wait(imagesToUpload.asMap().entries.map((entry) async {
        final index = entry.key;
        final imageFile = entry.value;
        final compressedFile = await ImageHelper.compressImage(imageFile);
        
        final uploadFolder = AppMediaFolders.activity(classroomId, 'batch_${DateTime.now().millisecondsSinceEpoch}');
        final imageUrl = await provider.uploadFile(compressedFile, uploadFolder);
        uploadedUrls[index] = imageUrl;

        if (compressedFile.path != imageFile.path) {
          await ImageHelper.deleteTempFile(compressedFile);
        }
      }));
    }

    final Map<String, String> studentImageUrls = {};
    for (int i = 0; i < studentIndicesForImages.length; i++) {
      final studentIndex = studentIndicesForImages[i];
      final studentId = studentActivities[studentIndex].studentId;
      studentImageUrls[studentId] = uploadedUrls[i];
    }

    final List<Map<String, dynamic>> logsData = [];
    for (var act in studentActivities) {
      final String finalContent = (act.content != null && act.content!.trim().isNotEmpty)
          ? act.content!.trim()
          : generalContent;
      
      logsData.add({
        'teacher_id': teacherId,
        'classroom_id': classroomId,
        'content': finalContent,
        'student_id': act.studentId,
      });
    }

    final insertedLogs = await provider.insertLogs(logsData);

    final List<Map<String, dynamic>> imagesToInsert = [];
    for (var log in insertedLogs) {
      final String logId = log['id'];
      final String? studentId = log['student_id'];
      if (studentId != null && studentImageUrls.containsKey(studentId)) {
        final imageUrl = studentImageUrls[studentId]!;
        imagesToInsert.add({
          'activity_id': logId,
          'image_url': imageUrl,
        });
      }
    }

    if (imagesToInsert.isNotEmpty) {
      await provider.insertImages(imagesToInsert);
    }
  }
}

class StudentActivityInput {
  final String studentId;
  final String? content;
  final File? image;

  StudentActivityInput({
    required this.studentId,
    this.content,
    this.image,
  });
}

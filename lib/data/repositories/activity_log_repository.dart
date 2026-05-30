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

    // 2. Upload ảnh và tạo bản ghi Image
    if (images.isNotEmpty) {
      final List<Map<String, dynamic>> imagesToInsert = [];
      final uploadFolder = AppMediaFolders.activity(classroomId, logId);
      
      for (var image in images) {
        // Nén ảnh trước khi tải lên
        final compressedFile = await ImageHelper.compressImage(image);
        
        final imageUrl = await provider.uploadFile(compressedFile, uploadFolder);
        
        imagesToInsert.add({
          'activity_id': logId,
          'image_url': imageUrl,
        });

        // Xóa file tạm thời sau khi tải lên để giải phóng bộ nhớ
        if (compressedFile.path != image.path) {
          await ImageHelper.deleteTempFile(compressedFile);
        }
      }

      await provider.insertImages(imagesToInsert);
    }
  }
}

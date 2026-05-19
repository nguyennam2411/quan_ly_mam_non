import '../models/lesson_model.dart';
import '../providers/lesson_provider.dart';

class LessonRepository {
  final LessonProvider _lessonProvider = LessonProvider();

  // Lấy chi tiết một bài học để chỉnh sửa
  Future<LessonModel?> getLessonDetail(String classroomId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final data = await _lessonProvider.getByDate(classroomId, dateStr);
    
    if (data.isEmpty) return null;
    return LessonModel.fromJson(data.first);
  }

  // Lưu hoặc cập nhật bài học (Cho nút "Đăng bài" hoặc "Lưu nháp")
  Future<LessonModel> saveLesson(LessonModel lesson) async {
    final data = await _lessonProvider.upsertLesson(lesson.toJson());
    return LessonModel.fromJson(data);
  }

  // Logic xóa bài học
  // Future<void> deleteLesson(String lessonId) async { ... }
}
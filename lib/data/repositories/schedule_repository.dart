import '../models/lesson_model.dart';
import '../models/schedule_model.dart';
import '../providers/lesson_provider.dart';
import '../providers/schedule_provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/values/app_database.dart';

// Class bao bọc để hiển thị trên UI
class ScheduleItem {
  final ScheduleModel? schedule; // Có thể null nếu là bài học tự do không theo khung giờ
  final LessonModel? lesson;   // Có thể null nếu giờ đó không phải giờ học hoặc chưa có bài

  ScheduleItem({this.schedule, this.lesson});
  
  // Getters tiện ích cho UI
  String get startTime => schedule?.startTime ?? (lesson != null ? "Bổ sung" : "--:--");
  String get endTime => schedule?.endTime ?? "";
  String get activityName => schedule?.activityName ?? lesson?.title ?? "Bài học tự do";
  bool get isLessonSlot => schedule?.isLessonSlot ?? true;
}

class ScheduleRepository {
  final ScheduleProvider _scheduleProvider = ScheduleProvider();
  final LessonProvider _lessonProvider = LessonProvider();

  Future<List<ScheduleItem>> getFullDailySchedule(String classroomId, DateTime date, {bool isParent = false}) async {
    try {
      // 1. Lấy TKB của thứ đó
      final dayOfWeek = date.weekday + 1; 
      final scheduleData = await _scheduleProvider.getByDay(classroomId, dayOfWeek);
      final allSchedules = scheduleData.map((e) => ScheduleModel.fromJson(e)).toList();

      // 2. Lấy danh sách bài học của ngày đó
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final lessonStatus = isParent ? AppDatabase.statusPublished : null;
      final lessonData = await _lessonProvider.getByDate(classroomId, dateStr, status: lessonStatus);
      final lessons = lessonData.map((e) => LessonModel.fromJson(e)).toList();

      List<ScheduleItem> results = [];
      Set<String> matchedLessonIds = {};

      // 3. Ghép bài học vào khung giờ cố định bằng schedule_id
      for (var schedule in allSchedules) {
        LessonModel? matchedLesson;
        
        if (schedule.isLessonSlot) {
          // Ghép chính xác bằng schedule_id
          matchedLesson = lessons.firstWhereOrNull((l) => l.scheduleId == schedule.id);
          
          if (matchedLesson != null && matchedLesson.id != null) {
            matchedLessonIds.add(matchedLesson.id!);
          }
        }
        results.add(ScheduleItem(schedule: schedule, lesson: matchedLesson));
      }

      // 4. Bổ sung các bài học còn lại (Những bài soạn tự do hoặc bài cũ chưa có schedule_id)
      for (var lesson in lessons) {
        if (lesson.id != null && !matchedLessonIds.contains(lesson.id)) {
          results.add(ScheduleItem(schedule: null, lesson: lesson));
        }
      }

      return results;
    } catch (e) {
      rethrow;
    }
  }
}
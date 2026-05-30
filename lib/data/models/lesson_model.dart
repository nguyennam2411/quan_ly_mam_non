import 'package:json_annotation/json_annotation.dart';
import '../../core/values/app_database.dart';
import '../../core/utils/date_helper.dart';

part 'lesson_model.g.dart';

@JsonSerializable()
class LessonModel {
  @JsonKey(name: AppDatabase.colId)
  final String? id;

  @JsonKey(name: AppDatabase.colClassroomId)
  final String classroomId;

  @JsonKey(name: AppDatabase.colScheduleId)
  final String? scheduleId;

  @JsonKey(name: AppDatabase.colTitle)
  final String title;

  @JsonKey(name: AppDatabase.colObjectives)
  final String? objectives;

  @JsonKey(name: AppDatabase.colContent)
  final String? content;

  @JsonKey(name: AppDatabase.colDate, fromJson: DateHelper.parseUtc)
  final DateTime date;

  @JsonKey(name: AppDatabase.colLessonImages)
  final List<String> images;

  @JsonKey(name: AppDatabase.colYoutubeUrl)
  final String? youtubeUrl;

  @JsonKey(name: AppDatabase.colAttachmentUrl)
  final String? attachmentUrl;

  @JsonKey(name: AppDatabase.colStatus)
  final String status;

  @JsonKey(name: AppDatabase.colCreatedAt, fromJson: DateHelper.parseUtc)
  final DateTime? createdAt;

  LessonModel({
    this.id,
    required this.classroomId,
    this.scheduleId,
    required this.title,
    this.objectives,
    this.content,
    required this.date,
    this.images = const [],
    this.youtubeUrl,
    this.attachmentUrl,
    this.status = AppDatabase.statusDraft,
    this.createdAt,
  });

  // Helper để lấy Video ID từ link Youtube
  String? get youtubeId {
    if (youtubeUrl == null || youtubeUrl!.isEmpty) return null;
    final uri = Uri.parse(youtubeUrl!);
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    } else if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    }
    return null;
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) => _$LessonModelFromJson(json);
  
  Map<String, dynamic> toJson() {
    final map = _$LessonModelToJson(this);
    // Loại bỏ id nếu là null để database tự sinh
    if (id == null) {
      map.remove(AppDatabase.colId);
    }
    // Đảm bảo định dạng ngày yyyy-MM-dd cho Supabase DATE column
    map[AppDatabase.colDate] = date.toIso8601String().split('T')[0];
    return map;
  }
}
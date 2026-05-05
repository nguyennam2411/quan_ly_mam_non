import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';
import '../../../core/utils/date_helper.dart';
import 'activity_comment_model.dart';
import 'activity_image_model.dart';
import 'student_model.dart';

part 'activity_log_model.g.dart';

@JsonSerializable(includeIfNull: false)
class ActivityLogModel {
  @JsonKey(name: AppDatabase.colId)
  final String? id;

  @JsonKey(name: AppDatabase.colClassroomId)
  final String classroomId;

  @JsonKey(name: AppDatabase.colTeacherId)
  final String teacherId;

  @JsonKey(name: AppDatabase.colStudentId)
  final String? studentId;

  @JsonKey(name: AppDatabase.colContent)
  final String content;

  @JsonKey(name: AppDatabase.colCreatedAt, fromJson: DateHelper.parseUtcNullable)
  final DateTime? createdAt;

  // Joined fields
  @JsonKey(name: AppDatabase.tableActivityImages, includeToJson: false)
  final List<ActivityImageModel>? images;

  @JsonKey(name: 'students', includeToJson: false)
  final StudentModel? student;

  // Like & Comment info
  @JsonKey(defaultValue: 0)
  final int likeCount;
  @JsonKey(defaultValue: 0)
  final int commentCount;
  @JsonKey(defaultValue: false)
  final bool isLiked;
  @JsonKey(includeToJson: false)
  final List<ActivityCommentModel>? comments;

  ActivityLogModel({
    this.id,
    required this.classroomId,
    required this.teacherId,
    this.studentId,
    required this.content,
    this.createdAt,
    this.images,
    this.student,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.comments,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    // Handle nested images if they come from Supabase select
    List<ActivityImageModel>? imageList;
    if (json[AppDatabase.tableActivityImages] != null) {
      imageList = (json[AppDatabase.tableActivityImages] as List)
          .map((i) => ActivityImageModel.fromJson(i))
          .toList();
    }

    // Handle comments
    List<ActivityCommentModel>? commentList;
    if (json['activity_comments'] != null) {
      commentList = (json['activity_comments'] as List)
          .map((i) => ActivityCommentModel.fromJson(i))
          .toList();
    }

    return ActivityLogModel(
      id: json[AppDatabase.colId],
      classroomId: json[AppDatabase.colClassroomId],
      teacherId: json[AppDatabase.colTeacherId],
      studentId: json[AppDatabase.colStudentId],
      content: json[AppDatabase.colContent],
      createdAt: json[AppDatabase.colCreatedAt] != null 
          ? DateHelper.parseUtcNullable(json[AppDatabase.colCreatedAt]) 
          : null,
      images: imageList,
      student: json['students'] != null ? StudentModel.fromJson(json['students']) : null,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      comments: commentList,
    );
  }

  Map<String, dynamic> toJson() => _$ActivityLogModelToJson(this);
}

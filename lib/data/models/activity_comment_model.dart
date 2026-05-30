import 'package:json_annotation/json_annotation.dart';
import '../../../core/utils/date_helper.dart';

part 'activity_comment_model.g.dart';

@JsonSerializable()
class ActivityCommentModel {
  final String id;
  @JsonKey(name: 'activity_log_id')
  final String activityLogId;
  @JsonKey(name: 'user_id')
  final String userId;
  final String content;
  @JsonKey(name: 'created_at', fromJson: DateHelper.parseUtc)
  final DateTime createdAt;
  
  // These might be joined from the users table
  @JsonKey(includeToJson: false)
  final String? userName;
  @JsonKey(includeToJson: false)
  final String? userRole;

  ActivityCommentModel({
    required this.id,
    required this.activityLogId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.userName,
    this.userRole,
  });

  factory ActivityCommentModel.fromJson(Map<String, dynamic> json) {
    // Extract user info from joined 'users' table
    String? name;
    String? role;
    
    if (json['users'] != null) {
      name = json['users']['name'];
      if (json['users']['user_roles'] != null && (json['users']['user_roles'] as List).isNotEmpty) {
        role = json['users']['user_roles'][0]['roles']['name'];
      }
    }

    return ActivityCommentModel(
      id: json['id'],
      activityLogId: json['activity_log_id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateHelper.parseUtc(json['created_at']),
      userName: name,
      userRole: role,
    );
  }
  Map<String, dynamic> toJson() => _$ActivityCommentModelToJson(this);
}

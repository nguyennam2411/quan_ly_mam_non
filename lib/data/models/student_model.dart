import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';
part 'student_model.g.dart';

@JsonSerializable()
class StudentModel {
  @JsonKey(name: AppDatabase.colId)
  final String id;
  
  @JsonKey(name: AppDatabase.colName)
  final String name;
  
  @JsonKey(name: AppDatabase.colClassroomId)
  final String? classroomId;
  
  @JsonKey(name: AppDatabase.colParentId)
  final String? parentId;
  
  @JsonKey(name: AppDatabase.colAvatarUrl)
  final String? avatarUrl;

  @JsonKey(includeToJson: false)
  final String? classroomName;

  StudentModel({
    required this.id, 
    required this.name, 
    this.classroomId, 
    this.parentId, 
    this.avatarUrl,
    this.classroomName,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    // Xử lý lấy tên lớp từ join query
    String? cName;
    if (json[AppDatabase.tableClassrooms] != null) {
      cName = json[AppDatabase.tableClassrooms][AppDatabase.colName];
    }
    
    return StudentModel(
      id: json[AppDatabase.colId] as String,
      name: json[AppDatabase.colName] as String,
      classroomId: json[AppDatabase.colClassroomId] as String?,
      parentId: json[AppDatabase.colParentId] as String?,
      avatarUrl: json[AppDatabase.colAvatarUrl] as String?,
      classroomName: cName,
    );
  }
  Map<String, dynamic> toJson() => _$StudentModelToJson(this);
}
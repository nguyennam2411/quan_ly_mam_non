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

  @JsonKey(includeToJson: false)
  final String? gradeId;

  @JsonKey(includeToJson: false)
  final String? gradeName;
  
  @JsonKey(name: AppDatabase.colBirthday)
  final DateTime? birthday;

  @JsonKey(name: AppDatabase.colGender)
  final String? gender; 

  StudentModel({
    required this.id, 
    required this.name, 
    this.classroomId, 
    this.parentId, 
    this.avatarUrl,
    this.classroomName,
    this.gradeId,
    this.gradeName,
    this.birthday,
    this.gender,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    // Xử lý lấy tên lớp và thông tin khối học từ join query
    String? cName;
    String? gId;
    String? gName;
    
    if (json[AppDatabase.tableClassrooms] != null) {
      cName = json[AppDatabase.tableClassrooms][AppDatabase.colName];
      gId = json[AppDatabase.tableClassrooms][AppDatabase.colGradeId];
      if (json[AppDatabase.tableClassrooms][AppDatabase.tableGrades] != null) {
        gName = json[AppDatabase.tableClassrooms][AppDatabase.tableGrades][AppDatabase.colName];
      }
    }
    
    return StudentModel(
      id: json[AppDatabase.colId] as String,
      name: json[AppDatabase.colName] as String,
      classroomId: json[AppDatabase.colClassroomId] as String?,
      parentId: json[AppDatabase.colParentId] as String?,
      avatarUrl: json[AppDatabase.colAvatarUrl] as String?,
      classroomName: cName,
      gradeId: gId,
      gradeName: gName,
      birthday: json[AppDatabase.colBirthday] != null 
          ? DateTime.parse(json[AppDatabase.colBirthday]) 
          : null,
      gender: json[AppDatabase.colGender] as String?,
    );
  }
  Map<String, dynamic> toJson() => _$StudentModelToJson(this);

  StudentModel copyWith({
    String? id,
    String? name,
    String? classroomId,
    String? parentId,
    String? avatarUrl,
    String? classroomName,
    String? gradeId,
    String? gradeName,
    DateTime? birthday,
    String? gender,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      classroomId: classroomId ?? this.classroomId,
      parentId: parentId ?? this.parentId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      classroomName: classroomName ?? this.classroomName,
      gradeId: gradeId ?? this.gradeId,
      gradeName: gradeName ?? this.gradeName,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
    );
  }
}
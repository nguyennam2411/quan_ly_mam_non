import '../models/student_model.dart';
import '../providers/student_provider.dart';

class StudentRepository {
  final StudentProvider _provider;

  StudentRepository(this._provider);

  Future<List<StudentModel>> getStudentsByParent(String parentId) async {
    final response = await _provider.getStudentsByParent(parentId);
    return response.map((json) => StudentModel.fromJson(json)).toList();
  }

  Future<StudentModel> getStudentById(String studentId) async {
    final response = await _provider.getStudentById(studentId);
    return StudentModel.fromJson(response);
  }
}

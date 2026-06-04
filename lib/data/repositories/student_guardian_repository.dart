import '../models/student_guardian_model.dart';
import '../providers/student_guardian_provider.dart';

class StudentGuardianRepository {
  final StudentGuardianProvider _provider;

  StudentGuardianRepository(this._provider);

  Future<List<StudentGuardianModel>> getGuardiansByStudent(String studentId) async {
    final response = await _provider.getGuardiansByStudent(studentId);
    return response.map((json) => StudentGuardianModel.fromJson(json)).toList();
  }

  Future<StudentGuardianModel> createGuardian(Map<String, dynamic> data) async {
    final response = await _provider.createGuardian(data);
    return StudentGuardianModel.fromJson(response);
  }

  Future<StudentGuardianModel> updateGuardian(String id, Map<String, dynamic> data) async {
    final response = await _provider.updateGuardian(id, data);
    return StudentGuardianModel.fromJson(response);
  }

  Future<void> deleteGuardian(String id) async {
    await _provider.deleteGuardian(id);
  }
}

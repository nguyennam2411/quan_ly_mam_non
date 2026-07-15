import '../models/talent_class_model.dart';
import '../models/talent_enrollment_model.dart';
import '../models/talent_attendance_model.dart';
import '../providers/talent_provider.dart';

class TalentRepository {
  final TalentProvider _provider = TalentProvider();

  Future<List<TalentClassModel>> getAllTalentClasses() async {
    final response = await _provider.getAllTalentClasses();
    return response.map((e) => TalentClassModel.fromJson(e)).toList();
  }

  Future<void> createTalentClass(TalentClassModel newClass) async {
    final data = newClass.toJson();
    data.removeWhere((key, value) => value == null);
    await _provider.createTalentClass(data);
  }

  Future<void> updateTalentClass(String classId, Map<String, dynamic> data) async {
    await _provider.updateTalentClass(classId, data);
  }

  Future<List<TalentEnrollmentModel>> getEnrollmentsByStudents(List<String> studentIds) async {
    final response = await _provider.getEnrollmentsByStudents(studentIds);
    return response.map((e) => TalentEnrollmentModel.fromJson(e)).toList();
  }

  Future<List<TalentEnrollmentModel>> getEnrollmentsByClass(String classId) async {
    final response = await _provider.getEnrollmentsByClass(classId);
    return response.map((e) => TalentEnrollmentModel.fromJson(e)).toList();
  }

  Future<void> submitEnrollment(TalentEnrollmentModel enrollment) async {
    final data = enrollment.toJson();
    data.removeWhere((key, value) => value == null);
    await _provider.submitEnrollment(data);
  }

  Future<List<TalentAttendanceModel>> getAttendanceByStudents(List<String> studentIds) async {
    final response = await _provider.getAttendanceByStudents(studentIds);
    return response.map((e) => TalentAttendanceModel.fromJson(e)).toList();
  }

  Future<void> submitAttendance(TalentAttendanceModel attendance) async {
    final data = attendance.toJson();
    data.removeWhere((key, value) => value == null);
    await _provider.submitAttendance(data);
  }
}

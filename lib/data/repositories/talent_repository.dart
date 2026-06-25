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
    await _provider.createTalentClass(newClass.toJson());
  }

  Future<List<TalentEnrollmentModel>> getEnrollmentsByStudents(List<String> studentIds) async {
    final response = await _provider.getEnrollmentsByStudents(studentIds);
    return response.map((e) => TalentEnrollmentModel.fromJson(e)).toList();
  }

  Future<void> submitEnrollment(TalentEnrollmentModel enrollment) async {
    await _provider.submitEnrollment(enrollment.toJson());
  }

  Future<List<TalentAttendanceModel>> getAttendanceByStudents(List<String> studentIds) async {
    final response = await _provider.getAttendanceByStudents(studentIds);
    return response.map((e) => TalentAttendanceModel.fromJson(e)).toList();
  }

  Future<void> submitAttendance(TalentAttendanceModel attendance) async {
    await _provider.submitAttendance(attendance.toJson());
  }
}

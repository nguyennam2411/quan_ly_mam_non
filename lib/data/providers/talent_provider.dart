import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/values/app_database.dart';

class TalentProvider {
  final _supabase = Supabase.instance.client;

  Future<List<dynamic>> getAllTalentClasses() async {
    return await _supabase
        .from(AppDatabase.tableTalentClasses)
        .select()
        .order(AppDatabase.colCreatedAt, ascending: false);
  }

  Future<void> createTalentClass(Map<String, dynamic> data) async {
    await _supabase.from(AppDatabase.tableTalentClasses).insert(data);
  }

  Future<List<dynamic>> getEnrollmentsByStudents(List<String> studentIds) async {
    if (studentIds.isEmpty) return [];
    return await _supabase
        .from(AppDatabase.tableTalentEnrollments)
        .select()
        .inFilter(AppDatabase.colStudentId, studentIds);
  }

  Future<void> submitEnrollment(Map<String, dynamic> data) async {
    await _supabase.from(AppDatabase.tableTalentEnrollments).upsert(
      data,
      onConflict: '${AppDatabase.colStudentId}, ${AppDatabase.colTalentClassId}',
    );
  }

  Future<List<dynamic>> getAttendanceByStudents(List<String> studentIds) async {
    if (studentIds.isEmpty) return [];
    return await _supabase
        .from(AppDatabase.tableTalentAttendance)
        .select()
        .inFilter(AppDatabase.colStudentId, studentIds)
        .order(AppDatabase.colDate, ascending: false);
  }

  Future<void> submitAttendance(Map<String, dynamic> data) async {
    await _supabase.from(AppDatabase.tableTalentAttendance).upsert(
      data,
      onConflict: '${AppDatabase.colStudentId}, ${AppDatabase.colTalentClassId}, ${AppDatabase.colDate}',
    );
  }
}

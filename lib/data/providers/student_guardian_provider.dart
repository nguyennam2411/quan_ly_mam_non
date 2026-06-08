import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/values/app_database.dart';

class StudentGuardianProvider {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getGuardiansByStudent(String studentId) async {
    final response = await _client
        .from(AppDatabase.tableStudentGuardians)
        .select()
        .eq(AppDatabase.colStudentId, studentId)
        .order(AppDatabase.colCreatedAt, ascending: true);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createGuardian(Map<String, dynamic> data) async {
    final response = await _client
        .from(AppDatabase.tableStudentGuardians)
        .insert(data)
        .select()
        .single();
    
    return response;
  }

  Future<Map<String, dynamic>> updateGuardian(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from(AppDatabase.tableStudentGuardians)
        .update(data)
        .eq(AppDatabase.colId, id)
        .select()
        .single();
    
    return response;
  }

  Future<void> deleteGuardian(String id) async {
    await _client
        .from(AppDatabase.tableStudentGuardians)
        .delete()
        .eq(AppDatabase.colId, id);
  }
}

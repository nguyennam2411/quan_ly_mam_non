import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/values/app_database.dart';

class StudentProvider {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getStudentsByParent(String parentId) async {
    final response = await _client
        .from(AppDatabase.tableStudents)
        .select('*, ${AppDatabase.tableClassrooms}(${AppDatabase.colName})')
        .eq(AppDatabase.colParentId, parentId)
        .order(AppDatabase.colName);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getStudentById(String studentId) async {
    final response = await _client
        .from(AppDatabase.tableStudents)
        .select('*, ${AppDatabase.tableClassrooms}(${AppDatabase.colName})')
        .eq(AppDatabase.colId, studentId)
        .single();
    
    return response;
  }

  Future<List<Map<String, dynamic>>> getStudentsByClassroom(String classroomId) async {
    final response = await _client
        .from(AppDatabase.tableStudents)
        .select()
        .eq(AppDatabase.colClassroomId, classroomId)
        .order(AppDatabase.colName);
    
    return List<Map<String, dynamic>>.from(response);
  }
}

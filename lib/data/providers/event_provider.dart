import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/values/app_database.dart';

class EventProvider {
  final _supabase = Supabase.instance.client;

  Future<List<dynamic>> getAllEvents() async {
    return await _supabase
        .from(AppDatabase.tableEvents)
        .select()
        .order(AppDatabase.colCreatedAt, ascending: false);
  }

  Future<List<dynamic>> getRegistrationsByStudents(List<String> studentIds) async {
    if (studentIds.isEmpty) return [];
    return await _supabase
        .from(AppDatabase.tableEventRegistrations)
        .select()
        .inFilter(AppDatabase.colStudentId, studentIds);
  }

  Future<List<dynamic>> getRegistrationsByEvent(String eventId, List<String> studentIds) async {
    if (studentIds.isEmpty) return [];
    return await _supabase
        .from(AppDatabase.tableEventRegistrations)
        .select()
        .eq(AppDatabase.colEventId, eventId)
        .inFilter(AppDatabase.colStudentId, studentIds);
  }

  Future<void> submitRegistration(Map<String, dynamic> data) async {
    await _supabase.from(AppDatabase.tableEventRegistrations).upsert(
      data,
      onConflict: '${AppDatabase.colEventId}, ${AppDatabase.colStudentId}',
    );
  }

  Future<void> createEvent(Map<String, dynamic> data) async {
    await _supabase.from(AppDatabase.tableEvents).insert(data);
  }

  Future<void> deleteEvent(String eventId) async {
    await _supabase.from(AppDatabase.tableEvents).delete().eq(AppDatabase.colId, eventId);
  }
}

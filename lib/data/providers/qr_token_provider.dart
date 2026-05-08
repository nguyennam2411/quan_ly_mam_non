import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/values/app_database.dart';

class QrTokenProvider {
  final _client = Supabase.instance.client;

  // Lấy mã QR của học sinh
  Future<Map<String, dynamic>?> getQrByStudentId(String studentId) async {
    return await _client
        .from(AppDatabase.tableQrTokens)
        .select()
        .eq(AppDatabase.colStudentId, studentId)
        .maybeSingle(); // Trả về null nếu chưa có mã
  }

  // Tạo mới mã QR cho học sinh
  Future<Map<String, dynamic>> createQrToken(Map<String, dynamic> data) async {
    // Lọc bỏ các trường null (đặc biệt là 'id': null) 
    // để tránh vi phạm RLS policy của Supabase
    final cleanData = Map<String, dynamic>.fromEntries(
      data.entries.where((e) => e.value != null),
    );
    return await _client
        .from(AppDatabase.tableQrTokens)
        .insert(cleanData)
        .select()
        .single();
  }
}
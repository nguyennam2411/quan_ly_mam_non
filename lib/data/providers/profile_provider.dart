import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/values/app_database.dart';

class ProfileProvider {
  final SupabaseClient _client = Supabase.instance.client;

  /// Cập nhật URL avatar trong bảng users, ép kiểu về `Map<String, dynamic>` sạch
  Future<Map<String, dynamic>> updateAvatar(String userId, String imageUrl) async {
    final response = await _client
        .from(AppDatabase.tableUsers)
        .update({AppDatabase.colAvatarUrl: imageUrl})
        .eq(AppDatabase.colId, userId)
        .select()
        .single();
    
    return Map<String, dynamic>.from(response);
  }
}

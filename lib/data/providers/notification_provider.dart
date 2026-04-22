// lib/data/providers/notification_provider.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/values/app_database.dart';

class NotificationProvider {
  final _client = Supabase.instance.client;

  // Lấy danh sách thông báo của User (mặc định giới hạn 20 cái mới nhất)
  Future<List<dynamic>> fetchNotifications(String userId, {int limit = 20}) async {
    return await _client
        .from(AppDatabase.tableNotifications)
        .select()
        .eq(AppDatabase.colUserId, userId)
        .order(AppDatabase.colCreatedAt, ascending: false)
        .limit(limit);
  }

  // Đếm số lượng chưa đọc trực tiếp từ DB
  Future<int> countUnreadNotifications(String userId) async {
    final response = await _client
        .from(AppDatabase.tableNotifications)
        .select('*')
        .eq(AppDatabase.colUserId, userId)
        .eq(AppDatabase.colIsRead, false)
        .count(CountOption.exact);
    
    return response.count;
  }

  // Lấy Stream để lắng nghe Realtime
  Stream<List<Map<String, dynamic>>> getNotificationStream(String userId) {
    return _client
        .from(AppDatabase.tableNotifications)
        .stream(primaryKey: [AppDatabase.colId])
        .eq(AppDatabase.colUserId, userId)
        .order(AppDatabase.colCreatedAt, ascending: false);
  }

  // Cập nhật trạng thái đã đọc
  Future<void> updateReadStatus(String id, bool isRead) async {
    await _client
        .from(AppDatabase.tableNotifications)
        .update({AppDatabase.colIsRead: isRead})
        .eq(AppDatabase.colId, id);
  }

  // Cập nhật trạng thái đã đọc cho tất cả thông báo của người dùng
  Future<void> markAllAsRead(String userId) async {
    await _client
        .from(AppDatabase.tableNotifications)
        .update({AppDatabase.colIsRead: true})
        .eq(AppDatabase.colUserId, userId)
        .eq(AppDatabase.colIsRead, false);
  }
}
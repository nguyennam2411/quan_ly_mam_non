// lib/data/repositories/notification_repository.dart
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationRepository {
  final NotificationProvider _provider = NotificationProvider();

  // Lấy danh sách thông báo và chuyển thành List Model
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final response = await _provider.fetchNotifications(userId);
    return (response as List)
        .map((item) => NotificationModel.fromJson(item))
        .toList();
  }

  // Đánh dấu đã đọc
  Future<void> markAsRead(String id) async {
    await _provider.updateReadStatus(id, true);
  }

  // Lấy số lượng thông báo chưa đọc (Tối ưu: chỉ lấy count, không tải data)
  Future<int> getUnreadCount(String userId) async {
    return await _provider.countUnreadNotifications(userId);
  }

  // Đánh dấu đã đọc cho tất cả
  Future<void> markAllAsRead(String userId) async {
    await _provider.markAllAsRead(userId);
  }

  // Cung cấp Stream để Controller lắng nghe Realtime
  Stream<List<NotificationModel>> getNotificationStream(String userId) {
    return _provider.getNotificationStream(userId).map((list) => 
        list.map((item) => NotificationModel.fromJson(item)).toList());
  }
}
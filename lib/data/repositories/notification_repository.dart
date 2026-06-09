// lib/data/repositories/notification_repository.dart
import 'package:uuid/uuid.dart';
import '../../../core/values/app_database.dart';
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

  // Tạo thông báo mới
  Future<void> createNotification({
    required String userId,
    required String title,
    required String content,
    String? type,
    String? referenceId,
  }) async {
    final data = {
      AppDatabase.colId: const Uuid().v4(),
      AppDatabase.colUserId: userId,
      AppDatabase.colTitle: title,
      AppDatabase.colContent: content,
      if (type != null) AppDatabase.colType: type,
      if (referenceId != null) AppDatabase.colReferenceId: referenceId,
      AppDatabase.colCreatedAt: DateTime.now().toUtc().toIso8601String(),
      AppDatabase.colIsRead: false,
    };
    await _provider.createNotification(data);
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
import 'dart:async';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/services/auth_service.dart';
import '../../../../core/values/user_role.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../widgets/notification_detail_dialog.dart';

class NotificationController extends GetxController {
  final NotificationRepository repository = Get.find();
  
  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;

  // Đếm số thông báo chưa đọc để hiện Badge ở thanh Tab
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  StreamSubscription? _notificationSubscription;

  @override
  void onInit() {
    super.onInit();
    // Khởi tạo ngôn ngữ Tiếng Việt cho Timeago
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    fetchNotifications();
    _initRealtime();
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    super.onClose();
  }

  void _initRealtime() {
    final userId = AuthService.to.currentUser.value?.id;
    if (userId != null) {
      _notificationSubscription = repository
          .getNotificationStream(userId)
          .listen((data) {
            notifications.assignAll(data);
          });
    }
  }
  // Lấy danh sách thông báo
  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final userId = AuthService.to.currentUser.value?.id;
      if (userId != null) {
        final data = await repository.getNotifications(userId);
        notifications.assignAll(data);
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  // Đánh dấu đã đọc
  Future<void> markAsRead(NotificationModel item) async {
    if (item.isRead) return;
    try {
      // Cập nhật DB trước
      await repository.markAsRead(item.id);
      
      // Chỉ khi DB thành công mới cập nhật UI Local
      item.isRead = true;
      notifications.refresh(); 
    } catch (e) {
      print('Lỗi đánh dấu đã đọc: $e');
      // Có thể hiện Snackbar thông báo lỗi ở đây
    }
  }

  // Đánh dấu đã đọc tất cả
  Future<void> markAllAsRead() async {
    final userId = AuthService.to.currentUser.value?.id;
    if (userId == null || unreadCount == 0) return;

    isLoading.value = true;
    try {
      await repository.markAllAsRead(userId);
      
      // Cập nhật tất cả item local sang đã đọc
      for (var n in notifications) {
        n.isRead = true;
      }
      notifications.refresh();
    } catch (e) {
      print('Lỗi đánh dấu đã đọc tất cả: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Hàm xử lý khi nhấn vào thông báo
  void onNotificationTap(NotificationModel item) {
    markAsRead(item);
    
    // Chỉ giáo viên mới chuyển hướng sang màn hình duyệt đơn để xử lý nhanh
    if (item.type == 'LEAVE_REQUEST' && UserRole.isTeacher(AuthService.to.userRole.value)) {
      Get.toNamed(Routes.TEACHER_LEAVE_REQUEST); 
    } else {
      // Đối với phụ huynh hoặc các loại thông báo khác, hiển thị Dialog chi tiết
      Get.dialog(NotificationDetailDialog(item: item));
    }
  }
}
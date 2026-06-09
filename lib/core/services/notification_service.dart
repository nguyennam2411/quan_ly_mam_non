import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quan_ly_mam_non/routes/app_routes.dart';
import 'auth_service.dart';
import 'parent_student_service.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final _supabase = Supabase.instance.client; 

  Future<NotificationService> init() async {
    // 1. Lắng nghe trạng thái đăng nhập
    _listenToAuthChanges();

    return this;
  }

  /// Cập nhật FCM Token lên cơ sở dữ liệu Supabase của User hiện tại (hỗ trợ nhiều thiết bị)
  Future<void> saveTokenToDatabase(String token) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Upsert thông tin token vào bảng user_devices
      await _supabase
          .from('user_devices')
          .upsert({
            'user_id': userId,
            'fcm_token': token,
            'device_type': GetPlatform.isAndroid ? 'android' : 'ios',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }, onConflict: 'fcm_token');
          
      debugPrint('FCM Token saved to user_devices successfully.');
    } catch (e) {
      debugPrint('Error saving FCM Token to user_devices: $e');
    }
  }

  //khởi tạo rxset để lưu danh sách các classroomId đã đăng ký
  final RxSet<String> _subscribedClassrooms = <String>{}.obs;
  
  //khởi tạo stream subscription để lắng nghe sự kiện auth
  StreamSubscription<AuthState>? _authSubscription;
  
  //khởi tạo worker để lắng nghe sự kiện classroomId
  Worker? _classroomWorker;



  /// Lắng nghe trạng thái auth thay đổi để cập nhật Token khi đăng nhập
  void _listenToAuthChanges() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) async {
      // Firebase is disabled
    });

    // Lắng nghe classroomId của Giáo viên thay đổi (Giáo viên đổi lớp hoặc đăng nhập)
    _classroomWorker = ever(AuthService.to.classroomId, (_) {
      syncClassroomSubscriptions();
    });
  }

  /// Xóa FCM Token của thiết bị hiện tại khỏi bảng user_devices khi đăng xuất (chạy trước khi session bị hủy)
  Future<void> clearTokenOnLogout() async {
    try {
      // Firebase is disabled

      
      // Hủy đăng ký tất cả các topic lớp học hiện tại
      await unsubscribeAllClassrooms();
    } catch (e) {
      debugPrint('Error clearing FCM Token on logout: $e');
    }
  }

  /// Đồng bộ hóa các topic lớp học được đăng ký (Hỗ trợ cả Giáo viên & Phụ huynh)
  Future<void> syncClassroomSubscriptions() async {
    try {
      final List<String> targetClassrooms = [];

      // 1. Nếu là Giáo viên, lấy classroomId được gán cho giáo viên đó
      if (AuthService.to.classroomId.value.isNotEmpty) {
        targetClassrooms.add(AuthService.to.classroomId.value);
      }

      // 2. Nếu là Phụ huynh, lấy danh sách classroomId từ học sinh của phụ huynh đó
      if (Get.isRegistered<ParentStudentService>()) {
        final parentService = ParentStudentService.to;
        final parentClassrooms = parentService.students
            .map((s) => s.classroomId)
            .where((id) => id != null && id.isNotEmpty)
            .cast<String>();
        targetClassrooms.addAll(parentClassrooms);
      }

      // Loại bỏ các ID bị trùng lặp
      final uniqueTargets = targetClassrooms.toSet();

      // Phân tách danh sách cần hủy đăng ký và danh sách cần đăng ký mới
      final toUnsubscribe = _subscribedClassrooms.difference(uniqueTargets);
      final toSubscribe = uniqueTargets.difference(_subscribedClassrooms);

      for (final id in toUnsubscribe) {
        await unsubscribeFromClassroom(id);
      }
      for (final id in toSubscribe) {
        await subscribeToClassroom(id);
      }
      
      debugPrint('Classroom subscriptions synced. Current topics: $_subscribedClassrooms');
    } catch (e) {
      debugPrint('Error syncing classroom subscriptions: $e');
    }
  }

  /// Đăng ký theo dõi thông báo theo Topic lớp học (Teacher & Parent của lớp đó)
  Future<void> subscribeToClassroom(String classroomId) async {
    // Firebase is disabled
  }

  /// Hủy đăng ký theo dõi thông báo theo Topic lớp học
  Future<void> unsubscribeFromClassroom(String classroomId) async {
    // Firebase is disabled
  }

  /// Hủy đăng ký tất cả các topic lớp học hiện tại (khi đăng xuất)
  Future<void> unsubscribeAllClassrooms() async {
    try {
      final List<String> currentSubscriptions = _subscribedClassrooms.toList();
      for (final id in currentSubscriptions) {
        await unsubscribeFromClassroom(id);
      }
      _subscribedClassrooms.clear();
      debugPrint('All classroom topics unsubscribed.');
    } catch (e) {
      debugPrint('Error unsubscribing all classrooms: $e');
    }
  }

  /// Thiết lập các listener bắt sự kiện nhận thông báo ở các trạng thái ứng dụng khác nhau
  void _handleNotificationClick() {
    debugPrint('Notification clicked. Navigating to Dashboard...');
    Get.offAllNamed(Routes.MAIN_DASHBOARD);
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _classroomWorker?.dispose();
    super.onClose();
  }
}

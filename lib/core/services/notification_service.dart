import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quan_ly_mam_non/routes/app_routes.dart';
import 'auth_service.dart';
import 'parent_student_service.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final _supabase = Supabase.instance.client; 

  Future<NotificationService> init() async {
    // 1. Yêu cầu quyền thông báo (iOS & Android 13+)
    await _requestPermission();

    // 2. Thiết lập FCM Token và lưu trữ
    await _setupToken();

    // 3. Lắng nghe trạng thái đăng nhập để cập nhật token động
    _listenToAuthChanges();

    // 4. Đăng ký các trình lắng nghe sự kiện
    _initListeners();

    return this;
  }

  /// Yêu cầu quyền thông báo từ hệ điều hành
  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('Firebase Notification Permission: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
  }

  /// Lấy FCM Token thiết bị hiện tại và cập nhật
  Future<void> _setupToken() async {
    try {
      // Đợi lấy token lần đầu
      String? token = await _fcm.getToken();
      debugPrint('FCM Token: $token');
      if (token != null) {
        await saveTokenToDatabase(token);
      }

      // Lắng nghe khi Token tự động làm mới (refresh)
      _tokenRefreshSubscription = _fcm.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM Token Refreshed: $newToken');
        await saveTokenToDatabase(newToken);
      });
    } catch (e) {
      debugPrint('Error setting up FCM Token: $e');
    }
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

  // Khai báo các subscription cho FCM để hủy khi dispose
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  /// Lắng nghe trạng thái auth thay đổi để cập nhật Token khi đăng nhập
  void _listenToAuthChanges() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session?.user != null) {
        debugPrint('FCM: User logged in, setting up FCM Token...');
        final token = await _fcm.getToken();
        if (token != null) {
          await saveTokenToDatabase(token);
        }
      }
    });

    // Lắng nghe classroomId của Giáo viên thay đổi (Giáo viên đổi lớp hoặc đăng nhập)
    _classroomWorker = ever(AuthService.to.classroomId, (_) {
      syncClassroomSubscriptions();
    });
  }

  /// Xóa FCM Token của thiết bị hiện tại khỏi bảng user_devices khi đăng xuất (chạy trước khi session bị hủy)
  Future<void> clearTokenOnLogout() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _supabase
            .from('user_devices')
            .delete()
            .eq('fcm_token', token);
        debugPrint('FCM Token deleted from user_devices on logout.');
      }
      
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
    if (classroomId.isEmpty) return;
    try {
      await _fcm.subscribeToTopic('classroom_$classroomId');
      _subscribedClassrooms.add(classroomId);
      debugPrint('Subscribed to topic: classroom_$classroomId');
    } catch (e) {
      debugPrint('Error subscribing to classroom topic classroom_$classroomId: $e');
    }
  }

  /// Hủy đăng ký theo dõi thông báo theo Topic lớp học
  Future<void> unsubscribeFromClassroom(String classroomId) async {
    if (classroomId.isEmpty) return;
    try {
      await _fcm.unsubscribeFromTopic('classroom_$classroomId');
      _subscribedClassrooms.remove(classroomId);
      debugPrint('Unsubscribed from topic: classroom_$classroomId');
    } catch (e) {
      debugPrint('Error unsubscribing from classroom topic classroom_$classroomId: $e');
    }
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
  void _initListeners() {
    // A. Khi ứng dụng đang mở ở tiền cảnh (Foreground)
    _onMessageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground Message Received: ${message.notification?.title}');
      
      final title = message.notification?.title ?? 'Thông báo';
      final body = message.notification?.body ?? '';

      // Hiển thị Custom Snackbar ở góc trên màn hình
      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        colorText: Colors.black87,
        icon: const Icon(Icons.notifications_active, color: Colors.amber, size: 28),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
        onTap: (_) => _handleNotificationClick(message),
      );
    });

    // B. Khi click thông báo từ khay thông báo lúc ứng dụng chạy ngầm (Background)
    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification clicked from Background: ${message.notification?.title}');
      _handleNotificationClick(message);
    });

    // C. Khi ứng dụng đang tắt hẳn (Terminated) và người dùng bấm vào thông báo để mở app
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('Application opened from Terminated state via Notification: ${message.notification?.title}');
        Future.delayed(const Duration(milliseconds: 600), () {
          _handleNotificationClick(message);
        });
      }
    });
  }

  /// Hàm điều hướng màn hình dựa trên dữ liệu payload đính kèm (data) từ thông báo gửi về
  void _handleNotificationClick(RemoteMessage message) {
    debugPrint('Notification clicked. Navigating to Dashboard...');
    
    // Điều hướng trực tiếp về màn hình chính (Home Dashboard)
    Get.offAllNamed(Routes.MAIN_DASHBOARD);
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _classroomWorker?.dispose();
    _tokenRefreshSubscription?.cancel();
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
    super.onClose();
  }
}

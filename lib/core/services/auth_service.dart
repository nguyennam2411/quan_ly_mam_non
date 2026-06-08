import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_routes.dart';
import '../values/app_database.dart';
import '../values/user_role.dart';
import 'parent_student_service.dart';
import 'notification_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final _supabase = Supabase.instance.client;
  
  // Thông tin người dùng hiện tại
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxString userRole = ''.obs;
  
  // Thông tin bổ sung cho Teacher/Parent
  final RxString classroomId = ''.obs; // Cực kỳ quan trọng cho Điểm danh
  final RxString classroomName = ''.obs; // Hiển thị trên Dashboard
  final RxString gradeId = ''.obs; // Dùng cho Thực đơn
  final RxMap userProfile = {}.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _supabase.auth.currentUser;
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      currentUser.value = data.session?.user;
      if (data.session?.user == null) {
        _clearUserData();
      } else {
        await refreshUserData(); // Tải lại Role và Profile khi login
      }
    });
  }

  // --- HÀM LOGIN ---
  Future<bool> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return true;
    } catch (e) {
      Get.snackbar('Lỗi đăng nhập', e.toString());
      return false;
    }
  }

  // --- LẤY DỮ LIỆU TỔNG HỢP ---
  Future<void> refreshUserData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // 1. Lấy Role
    await fetchUserRole();

    // 2. Lấy Profile
    try {
      final profile = await _supabase
          .from(AppDatabase.tableUsers)
          .select()
          .eq(AppDatabase.colId, userId)
          .single();
      userProfile.value = profile;
    } catch (e) {
      print("Error fetching profile: $e");
    }

    // 3. Nếu là GV, lấy ClassroomId từ bảng classrooms
    if (userRole.value == UserRole.teacher ) {
      try {
        print("DEBUG: Fetching classroom for teacher: $userId");
        final classData = await _supabase
            .from(AppDatabase.tableClassrooms)
            .select('${AppDatabase.colId}, ${AppDatabase.colName}, ${AppDatabase.colGradeId}')
            .eq(AppDatabase.colTeacherId, userId)
            .maybeSingle();
        
        if (classData != null) {
          classroomId.value = classData[AppDatabase.colId];
          classroomName.value = classData[AppDatabase.colName];
          gradeId.value = classData[AppDatabase.colGradeId];
          print("DEBUG: Fetched classroomId: ${classroomId.value}, gradeId: ${gradeId.value}");
        } else {
          print("DEBUG: No classroom found for teacher: $userId");
        }
      } catch (e) {
        print("Error fetching classroom: $e");
      }
    }

    // MỚI: Tự động tải danh sách con nếu là Phụ huynh
    if (userRole.value == UserRole.parent) {
      try {
        if (Get.isRegistered<ParentStudentService>()) {
          ParentStudentService.to.fetchStudents();
        }
      } catch (e) {
        print("Error fetching students: $e");
      }
    }
  }

  Future<String> fetchUserRole() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return '';

      final response = await _supabase
          .from(AppDatabase.tableUserRoles)
          .select('${AppDatabase.tableRoles}(${AppDatabase.colName})')
          .eq(AppDatabase.colUserId, userId)
          .single();

      final roleName = response[AppDatabase.tableRoles][AppDatabase.colName] as String;
      userRole.value = roleName;
      return roleName;
    } catch (e) {
      return '';
    }
  }

  void _clearUserData() {
    userRole.value = '';
    classroomId.value = '';
    classroomName.value = '';
    gradeId.value = '';
    userProfile.clear();

    // MỚI: Xóa thông tin con khi đăng xuất
    try {
      if (Get.isRegistered<ParentStudentService>()) {
        ParentStudentService.to.clear();
      }
    } catch (_) {}
  }

  Future<void> signOut() async {
    // 1. Xóa FCM Token của thiết bị này trên DB trước khi hủy session (để tránh lỗi RLS)
    try {
      if (Get.isRegistered<NotificationService>()) {
        await NotificationService.to.clearTokenOnLogout();
      }
    } catch (e) {
      Get.log("Error clearing token on logout: $e", isError: true);
    }

    // 2. Tiến hành đăng xuất khỏi Supabase
    await _supabase.auth.signOut();
    _clearUserData();
    Get.offAllNamed(Routes.LOGIN);
  }

  bool get isLoggedIn => _supabase.auth.currentSession != null;
}
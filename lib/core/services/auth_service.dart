import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_routes.dart';
import '../values/app_database.dart';

class AuthService extends GetxService {
  // Để gọi nhanh ở các controller khác: AuthService.to.user
  static AuthService get to => Get.find();

  final _supabase = Supabase.instance.client;
  
  // Các biến quan sát (Rx) để UI tự động cập nhật nếu cần
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxString userRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Lắng nghe sự thay đổi trạng thái đăng nhập (Login/Logout)
    _supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
      if (data.session?.user == null) {
        userRole.value = '';
      }
    });
  }

  // Hàm kiểm tra trạng thái login khi vừa mở App (dùng cho Splash)
  bool get isLoggedIn => _supabase.auth.currentSession != null;

  // Hàm lấy Role từ Database (vì Role nằm ở bảng public.user_roles)
  Future<String> fetchUserRole() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return '';

      // Query bảng user_roles để lấy tên Role
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


  Future<void> signOut() async {
    await _supabase.auth.signOut();
    userRole.value = '';
    Get.offAllNamed(Routes.LOGIN);
  }
}
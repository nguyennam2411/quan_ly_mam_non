import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'core/services/supabase_service.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'core/values/app_strings.dart';
import 'routes/app_pages.dart';

Future<void> main() async {
  // 1. Phải có ensureInitialized vì chúng ta gọi Native Code (Supabase) trước runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load biến môi trường từ .env
  await dotenv.load(fileName: ".env");

  // 3. Khởi tạo Supabase Service bằng GetX
  await Get.putAsync(() => SupabaseService().init());

  // 4. Khởi tạo AuthService
  Get.put(AuthService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

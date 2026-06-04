import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/services/supabase_service.dart';
import 'core/services/cloudinary_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/values/app_strings.dart';
import 'routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // 1. Phải có ensureInitialized vì chúng ta gọi Native Code (Supabase) trước runApp
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);

  // 2. Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 3. Load biến môi trường từ .env
  await dotenv.load(fileName: ".env");

  // 4. Khởi tạo Supabase Service bằng GetX
  await Get.putAsync(() => SupabaseService().init());
  await Get.putAsync(() => CloudinaryService().init());

  // 5. Khởi tạo AuthService trước (vì NotificationService phụ thuộc vào AuthService)
  Get.put(AuthService());

  await Get.putAsync(() => NotificationService().init());

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

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService extends GetxService {
  static SupabaseService get to => Get.find();
  
  late SupabaseClient client;

  Future<SupabaseService> init() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    client = Supabase.instance.client;
    return this;
  }
}
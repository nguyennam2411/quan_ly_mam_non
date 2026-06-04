import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../values/app_strings.dart';

class AppErrorMessage {
  AppErrorMessage._();

  static String from(dynamic error) {
    if (error == null) return AppStrings.errorGeneric;

    // Check if error is a string
    if (error is String) {
      return _cleanAndFormat(error);
    }

    // Handled typed Supabase errors
    if (error is AuthException) {
      final msg = error.message;
      if (msg.contains('Invalid login credentials') || msg.contains('Email or password invalid')) {
        return AppStrings.errorLoginFailed;
      }
      if (msg.contains('Email not found') || msg.contains('User not found')) {
        return AppStrings.errorEmailNotFound;
      }
      if (msg.contains('Invalid OTP') || msg.contains('OTP has expired')) {
        return AppStrings.errorInvalidOtp;
      }
      return _cleanAndFormat(msg);
    }

    if (error is PostgrestException) {
      if (error.message.contains(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễđìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹ]', caseSensitive: false))) {
        return _cleanAndFormat(error.message);
      }
      if (error.code == '401') {
        return AppStrings.errorUnauthorized;
      }
      return AppStrings.errorGeneric;
    }

    // Network & Timeout exceptions
    if (error is SocketException) {
      return AppStrings.errorNetwork;
    }
    if (error is TimeoutException) {
      return AppStrings.errorTimeout;
    }

    // General string checks for standard exception objects
    final errorStr = error.toString();
    
    if (errorStr.contains('SocketException') || errorStr.contains('Network') || errorStr.contains('Failed host lookup')) {
      return AppStrings.errorNetwork;
    }
    if (errorStr.contains('TimeoutException') || errorStr.contains('timeout')) {
      return AppStrings.errorTimeout;
    }
    if (errorStr.contains('401') || errorStr.contains('Unauthorized') || errorStr.contains('JWT expired')) {
      return AppStrings.errorUnauthorized;
    }

    return _cleanAndFormat(errorStr);
  }

  static String _cleanAndFormat(String message) {
    String cleaned = message;
    if (cleaned.startsWith('Exception:')) {
      cleaned = cleaned.substring('Exception:'.length).trim();
    } else if (cleaned.startsWith('Exception')) {
      cleaned = cleaned.substring('Exception'.length).trim();
    }
    return cleaned;
  }
}

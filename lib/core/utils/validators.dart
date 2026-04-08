import 'package:form_validator/form_validator.dart';
import '../values/app_strings.dart';

class AppValidators {
  // Validator cho Email
  static String? Function(String?) email = ValidationBuilder(localeName: 'vi')
      .email(AppStrings.errorInvalidEmail)
      .required(AppStrings.errorEmptyField)
      .build();

  // Validator cho Mật khẩu
  static String? Function(String?) password = ValidationBuilder(localeName: 'vi')
      .minLength(6, AppStrings.errorPasswordLength)
      .required(AppStrings.errorEmptyField)
      .build();

  // Validator xác nhận mật khẩu (So sánh với mật khẩu mới)
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorEmptyField;
    }
    if (value != originalPassword) {
      return "Mật khẩu xác nhận không trùng khớp";
    }
    return null;
  }
}
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
      return AppStrings.errorPasswordMatch;
    }
    return null;
  }

  // Validator cho một trường bắt buộc trong form
  static String? Function(String?) requiredField(String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '${AppStrings.errorInputRequired} $fieldName';
      }
      return null;
    };
  }

  // Kiểm tra chuỗi rỗng trực tiếp trong Controller
  static String? requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorRequiredText;
    }
    return null;
  }

  // Kiểm tra dải ngày hợp lệ
  static String? dateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return AppStrings.errorDateRangeInvalid;
    }
    if (start.isAfter(end)) {
      return AppStrings.errorStartDateAfterEnd;
    }
    return null;
  }

  // Kiểm tra URL YouTube không bắt buộc
  static String? optionalYoutubeUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final url = value.trim().toLowerCase();
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return null;
    }
    return AppStrings.errorInvalidYoutube;
  }

  // Alias cho requiredField
  static String? Function(String?) required(String fieldName) => requiredField(fieldName);

  // Kiểm tra độ dài tối thiểu của chuỗi
  static String? Function(String?) minLength(int length, String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;
      if (value.trim().length < length) {
        return '$fieldName ${AppStrings.errorMinLengthSuffix} $length ${AppStrings.errorMinLengthChars}';
      }
      return null;
    };
  }

  // Kiểm tra ngày bắt buộc
  static String? dateRequired(DateTime? date, String fieldName) {
    if (date == null) {
      return '${AppStrings.errorSelectRequired} $fieldName';
    }
    return null;
  }

  // Kiểm tra lý do xin nghỉ bắt buộc
  static String? reasonRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorEmptyLeaveReason;
    }
    return null;
  }

  // Kiểm tra tiêu đề bài học bắt buộc
  static String? titleRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorEmptyLessonTitle;
    }
    return null;
  }

  // Alias cho optionalYoutubeUrl
  static String? youtubeUrlOptional(String? value) => optionalYoutubeUrl(value);
}
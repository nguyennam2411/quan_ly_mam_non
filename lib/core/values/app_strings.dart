class AppStrings {
  AppStrings._();

  // Branding
  static const String appName = 'Mầm Non Sao Mai';
  static const String appSlogan = 'Khơi dậy tiềm năng, thắp sáng tương lai';
  static const String contactSupport = 'Liên hệ tổng đài';
  static const String needHelp = 'Bạn cần hỗ trợ?';

  // Login
  static const String loginTitle = 'Đăng nhập';
  static const String loginButton = 'Đăng nhập';
  static const String emailHint = 'Email đăng nhập';
  static const String passwordHint = 'Mật khẩu';
  static const String forgotPasswordAction = 'Quên mật khẩu?';

  // Forgot Password
  static const String forgotPasswordTitle = 'Khôi phục mật khẩu';
  static const String forgotPasswordDesc = 'Vui lòng nhập email đã đăng ký để nhận mã OTP.';
  static const String sendOtpButton = 'Gửi OTP';

  // OTP Verification
  static const String otpTitle = 'Xác nhận OTP';
  static const String otpDesc = 'Nhập mã OTP gồm 6 chữ số đã được gửi tới Email của bạn.';
  static const String otpNotReceived = 'Bạn chưa nhận được mã?';
  static const String otpResend = 'Gửi lại mã';
  static const String confirmOtpButton = 'Xác nhận';

  // Reset Password
  static const String resetPasswordTitle = 'Thiết lập mật khẩu mới';
  static const String resetPasswordDesc = 'Vui lòng nhập mật khẩu mới để bảo mật tài khoản của bạn.';
  static const String newPasswordHint = 'Mật khẩu mới';
  static const String confirmPasswordHint = 'Xác nhận mật khẩu';
  static const String resetPasswordHint = 'Mật khẩu nên chứa ít nhất 6 ký tự.';
  static const String resetPasswordButton = 'Cập nhật mật khẩu';
  
  // Validation
  static const String errorEmptyField = 'Vui lòng không để trống';
  static const String errorInvalidEmail = 'Email không hợp lệ';
  static const String errorPasswordLength = 'Mật khẩu ít nhất 6 ký tự';
  static const String errorPasswordMatch = 'Mật khẩu không khớp';

  // State Messages
  static const String successTitle = 'Thành công';
  static const String errorTitle = 'Lỗi';
  static const String successUpdatePassword = 'Mật khẩu đã được đổi thành công. Vui lòng đăng nhập lại.';
  static const String errorUpdatePassword = 'Không thể cập nhật mật khẩu. Vui lòng thử lại.';
  static const String errorEmailNotFound = 'Không tìm thấy tài khoản với email này';
  static const String errorInvalidOtp = 'Mã xác thực không đúng hoặc đã hết hạn';

  // Error Messages
  static const String errorLoginFailed = 'Email hoặc mật khẩu không chính xác';

  // Navigation Tabs
  static const String tabHome = 'Trang chủ';
  static const String tabMessage = 'Tin nhắn';
  static const String tabNotification = 'Thông báo';
  static const String tabProfile = 'Tài khoản';
}

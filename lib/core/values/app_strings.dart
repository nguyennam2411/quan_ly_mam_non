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

  // Attendance
  static const String attendanceTitle = 'Điểm danh';
  static const String attendanceHeader = 'Hôm nay lớp thế nào?';
  static const String attendanceTimeInfo = 'THỜI GIAN ĐIỂM DANH';
  static const String attendanceCurrentDate = 'Ngày hiện tại';
  static const String attendanceStart = 'Bắt đầu điểm danh';
  static const String attendanceHistory = 'Xem lịch sử điểm danh';
  static const String attendanceFooterHint = 'Hệ thống sẽ tự động hiển thị danh sách học\nsinh theo thời khóa biểu hiện tại lớp.';
  static const String attendanceSelectDate = 'Chọn ngày điểm danh';
  
  static const String attendanceListTitle = 'Điểm danh lớp';
  static const String attendanceQuickAll = 'Tất cả có mặt';
  static const String attendanceSearchHint = 'Tìm kiếm tên học sinh...';
  static const String attendanceSearchNoResults = 'Không có kết quả nào khớp với';
  static const String attendanceNotFound = 'Không tìm thấy học sinh';
  static const String attendanceNoStudents = 'Danh sách lớp hiện chưa có học sinh nào.';
  static const String attendanceSubmit = 'Xác nhận Điểm danh';
  static const String attendanceSaveChange = 'Lưu thay đổi';
  static const String attendanceFutureWarning = 'Không thể điểm danh cho ngày trong tương lai';

  static const String attendanceHistoryTitle = 'Lịch sử điểm danh';
  static const String attendanceHistorySubtitle = 'Xem lại tình hình đi học và chuyên cần của bé';
  static const String attendanceLockEdit = 'Khóa chỉnh sửa';
  static const String attendanceEnableEdit = 'Bật chỉnh sửa';
  static const String attendanceEmptyHistory = 'Trống dữ liệu';
  static const String attendanceStats = 'Sĩ số hiện diện';
  static const String attendanceLegendFull = 'Điểm danh đủ';
  static const String attendanceLegendMissing = 'Có trẻ vắng';
  static const String attendanceSummaryHeader = 'Tổng hợp hôm nay';
  static const String attendanceSummaryTitle = 'Tình hình lớp học';
  static const String attendanceTotal = 'Tổng số';
  static const String attendancePresentLabel = 'Hiện diện';
  static const String attendanceAbsentLabel = 'Vắng mặt';
  
  static const String attendancePresent = 'Có mặt';
  static const String attendanceExcused = 'Nghỉ phép';
  static const String attendanceUnexcused = 'Vắng mặt';
  static const String attendanceUnknown = 'Chưa rõ';
  static const String attendanceNotTaken = 'Chưa điểm danh';
  static const String attendanceCheckinAt = 'Đến';

  static const String attendanceSuccess = 'Dữ liệu điểm danh đã được cập nhật.';
  static const String attendanceErrorLoad = 'Không thể tải danh sách học sinh';
  static const String attendanceErrorSave = 'Không thể lưu dữ liệu';
  static const String attendanceNoClass = 'Tài khoản của bạn chưa được gán lớp học nào. Vui lòng liên hệ Quản trị viên.';
  static const String attendanceStatusConflict = 'Bé đã có đơn xin nghỉ phép từ phụ huynh.';
  static const String attendanceNoSelection = 'Vui lòng chọn trạng thái cho học sinh.';
  static const String attendanceNotice = 'Lưu ý';
  static const String attendanceWarning = 'Thông báo';

  static const String statsMonthlyRatio = 'Tỷ lệ trong tháng';
  static const String statsWeeklyTrend = 'Biến động trong tuần';
  static const String statsSchoolDays = 'Số ngày học';
  static const String statsAttendanceRate = 'Tỷ lệ đi học';
  static const String statsNoData = 'Không có dữ liệu';
  static const String statsWeeklyNoData = 'Không có dữ liệu tuần này';
  static const String statsChange = 'Thay đổi';

  // Student Schedule
  static const String scheduleTitle = 'Lịch sinh hoạt';
  static const String scheduleSubtitle = 'Theo dõi các hoạt động học tập và vui chơi hàng ngày của bé';

  // Meal Plan
  static const String mealPlanTitle = 'Thực đơn';
  static const String mealPlanSubtitle = 'Thực đơn dinh dưỡng và các món ăn trong tuần của bé';

  // Health
  static const String healthTitle = 'Sức khỏe & Phát triển';
  static const String healthSubtitle = 'Theo dõi các chỉ số phát triển chiều cao, cân nặng của bé';
  static const String healthTeacherSubtitle = 'Cập nhật và theo dõi chỉ số phát triển của học sinh trong lớp';

  // Dialogs
  static const String dialogConfirmTitle = 'Xác nhận';
  static const String dialogWarningTitle = 'Cảnh báo';
  static const String dialogExitTitle = 'Chưa lưu thay đổi';
  static const String dialogExitMessage = 'Dữ liệu bạn vừa thay đổi sẽ không được lưu lại. Bạn có chắc chắn muốn thoát?';
  static const String dialogSaveMessage = 'Bạn có chắc chắn muốn lưu lại các thay đổi này không?';
  static const String dialogAgree = 'Đồng ý';
  static const String dialogCancel = 'Hủy bỏ';

  // Leave Request
  static const String leaveRequestTitle = 'Đơn xin nghỉ';
  static const String leaveRequestSubtitle = 'Theo dõi và quản lý các đơn xin nghỉ học của bé';
  static const String leaveRequestSearchHint = 'Tìm kiếm tên học sinh...';
  static const String leaveRequestSort = 'Sắp xếp';
  static const String leaveRequestCancel = 'Huỷ yêu cầu';
  static const String leaveRequestDetail = 'Chi tiết';
  static const String leaveRequestDetailTitle = 'Chi tiết đơn xin nghỉ';
  static const String leaveRequestReasonLabel = 'Lý do:';
  static const String leaveRequestSentAt = 'Gửi lúc';
  static const String leaveRequestTimeInfo = 'THỜI GIAN NGHỈ';
  static const String leaveRequestReasonInfo = 'LÝ DO';
  static const String leaveRequestEvidenceInfo = 'MINH CHỨNG (HÌNH ẢNH)';
  static const String leaveRequestClose = 'Đóng';
  static const String leaveRequestCreateTitle = 'Tạo đơn xin nghỉ';
  static const String leaveRequestFormDate = 'Thời gian nghỉ';
  static const String leaveRequestFormReason = 'Lý do xin nghỉ';
  static const String leaveRequestFormEvidence = 'Ảnh minh chứng (nếu có)';
  static const String leaveRequestFormSubmit = 'Gửi đơn xin nghỉ';
  static const String leaveRequestFormReasonHint = 'Vui lòng nhập lý do...';
  static const String leaveRequestCancelReasonHint = 'Lý do hủy (không bắt buộc)...';
  static const String leaveRequestSelectDate = 'Chọn ngày';
  
  static const String leaveStatusAll = 'Tất cả';
  static const String leaveStatusPending = 'Đang chờ';
  static const String leaveStatusApproved = 'Đã duyệt';
  static const String leaveStatusRejected = 'Từ chối';
  static const String leaveStatusCancelled = 'Đã hủy';

  // Medication Request
  static const String medicationStatusPending = 'Chưa cho uống';
  static const String medicationStatusCompleted = 'Đã cho uống';

  static const String leaveRequestTeacherHeader = 'Đơn xin nghỉ';
  static const String leaveRequestTeacherSubtitle = 'Theo dõi và phê duyệt lịch nghỉ của học sinh';
  static const String leaveRequestApprove = 'Duyệt';
  static const String leaveRequestReject = 'Từ chối';
  static const String leaveRequestUndoApproval = 'Hủy duyệt';
  static const String leaveRequestConfirmApprove = 'Xác nhận duyệt đơn xin nghỉ này?';
  static const String leaveRequestConfirmReject = 'Xác nhận từ chối đơn xin nghỉ này?';
  static const String leaveRequestConfirmUndoApproval = 'Xác nhận hủy phê duyệt đơn xin nghỉ này?';
  static const String leaveRequestCancelReasonInfoLabel = 'LÝ DO HỦY/TỪ CHỐI';
  
  static const String leaveRequestNoData = 'Không có đơn nào';
  static const String leaveRequestEmptyParent = 'Bạn chưa gửi đơn xin nghỉ nào hoặc không có đơn ở trạng thái này.';
  static const String leaveRequestEmptyTeacher = 'Không tìm thấy đơn xin nghỉ học nào khớp với điều kiện lọc.';
  static const String leaveRequestConfirmCancel = 'Bạn có chắc chắn muốn hủy yêu cầu xin nghỉ này không?';
  static const String leaveRequestConfirmSubmit = 'Bạn có chắc chắn muốn gửi đơn xin nghỉ này không?';
  static const String leaveRequestAutoCancel = 'Phụ huynh tự hủy';
  static const String leaveRequestSelectRange = 'Chọn dải ngày nghỉ';
  static const String leaveRequestPickImage = 'Chọn ảnh từ thư viện';
  static const String leaveRequestEvidenceTitle = 'Minh chứng nghỉ học';
  static const String unknownLabel = 'Không rõ';
  static const String classLabel = 'Lớp:';
  static const String noClassAssigned = 'Chưa gán';
  static const String confirmLabel = 'Xác nhận';

  // Notifications
  static const String notificationTitle = 'Thông báo';
  static const String notificationEmpty = 'Bạn không có thông báo nào mới.';
  static const String notificationMarkAllRead = 'Đánh dấu đã đọc tất cả';
}

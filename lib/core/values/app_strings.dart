class AppStrings {
  AppStrings._();

  // ===========================================================================
  // 1. Branding
  // ===========================================================================
  static const String appName = 'Mầm Non Sao Mai';
  static const String appSlogan = 'Khơi dậy tiềm năng, thắp sáng tương lai';
  static const String contactSupport = 'Liên hệ tổng đài';
  static const String needHelp = 'Bạn cần hỗ trợ?';

  // ===========================================================================
  // 2. Authentication & Authorization
  // ===========================================================================
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

  // ===========================================================================
  // 3. Navigation & Dashboard
  // ===========================================================================
  // Navigation Tabs
  static const String tabHome = 'Trang chủ';
  static const String tabEvent = 'Sự kiện';
  static const String tabNotification = 'Thông báo';
  static const String tabProfile = 'Tài khoản';

  // Home/Dashboard Menu & UI
  static const String homeUtilities = 'Tiện ích hệ thống';
  static const String menuAttendance = 'Điểm danh';
  static const String menuLeave = 'Nghỉ phép';
  static const String menuMedication = 'Dặn thuốc';
  static const String menuLog = 'Nhật ký';
  static const String menuSchedule = 'Lịch dạy';
  static const String menuParentSchedule = 'Sinh hoạt';
  static const String menuMeals = 'Thực đơn';
  static const String menuInvoice = 'Học phí';
  static const String menuHealth = 'Sức khỏe';
  static const String menuAttendanceHistory = 'Chuyên cần';
  static const String menuLeaveRequest = 'Xin nghỉ';
  
  static const String labelTeacher = 'Giáo viên';
  static const String labelParent = 'Phụ huynh học sinh';
  static const String classroomCurrent = 'LỚP HỌC HIỆN TẠI';
  static const String classroomDetail = 'Chi tiết lớp học';
  static const String studentInfo = 'THÔNG TIN BÉ';
  static const String classStatsPrefix = 'Sĩ số:';
  static const String classStatsSuffix = 'học sinh';
  static const String selectChild = 'Chọn con';
  
  static const String classroomMealTitle = 'Thực đơn của lớp';
  static const String loadingShort = 'Đang tải...';
  static const String noStudentInfo = 'Không tìm thấy thông tin học sinh';
  static const String labelStudentQr = 'QR bé';
  static const String studentQrTitle = 'Mã QR của bé';

  // ===========================================================================
  // 4. Attendance, Statistics & QR Scanner
  // ===========================================================================
  // General Attendance
  static const String attendanceTitle = 'Điểm danh';
  static const String attendanceHeader = 'Hôm nay lớp thế nào?';
  static const String attendanceTimeInfo = 'THỜI GIAN ĐIỂM DANH';
  static const String attendanceCurrentDate = 'Ngày hiện tại';
  static const String attendanceStart = 'Bắt đầu điểm danh';
  static const String attendanceHistory = 'Xem lịch sử điểm danh';
  static const String attendanceFooterHint = 'Hệ thống sẽ tự động hiển thị danh sách học\nsinh theo thời khóa biểu hiện tại lớp.';
  static const String attendanceSelectDate = 'Chọn ngày điểm danh';
  
  // Attendance List
  static const String attendanceListTitle = 'Điểm danh lớp';
  static const String attendanceQuickAll = 'Tất cả có mặt';
  static const String attendanceSearchHint = 'Tìm kiếm tên học sinh...';
  static const String attendanceSearchNoResults = 'Không có kết quả nào khớp với';
  static const String attendanceNotFound = 'Không tìm thấy học sinh';
  static const String attendanceNoStudents = 'Danh sách lớp hiện chưa có học sinh nào.';
  static const String attendanceSubmit = 'Xác nhận Điểm danh';
  static const String attendanceSaveChange = 'Lưu thay đổi';
  static const String attendanceFutureWarning = 'Không thể điểm danh cho ngày trong tương lai';

  // Attendance History
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
  
  // Attendance Statuses
  static const String attendancePresent = 'Có mặt';
  static const String attendanceExcused = 'Nghỉ phép';
  static const String attendanceUnexcused = 'Vắng mặt';
  static const String attendanceUnknown = 'Chưa rõ';
  static const String attendanceNotTaken = 'Chưa điểm danh';
  static const String attendanceCheckinAt = 'Đến';

  // Attendance Status Messages
  static const String attendanceSuccess = 'Dữ liệu điểm danh đã được cập nhật.';
  static const String attendanceErrorLoad = 'Không thể tải danh sách học sinh';
  static const String attendanceErrorSave = 'Không thể lưu dữ liệu';
  static const String attendanceNoClass = 'Tài khoản của bạn chưa được gán lớp học nào. Vui lòng liên hệ Quản trị viên.';
  static const String attendanceStatusConflict = 'Bé đã có đơn xin nghỉ phép từ phụ huynh.';
  static const String attendanceNoSelection = 'Vui lòng chọn trạng thái cho học sinh.';
  static const String attendanceNotice = 'Lưu ý';
  static const String attendanceWarning = 'Thông báo';

  // Statistics
  static const String statsTitle = 'Thống kê';
  static const String statsAttendanceTitle = 'Thống kê chuyên cần';
  static const String statsMonthlyRatio = 'Tỷ lệ trong tháng';
  static const String statsWeeklyTrend = 'Biến động trong tuần';
  static const String statsSchoolDays = 'Số ngày học';
  static const String statsAttendanceRate = 'Tỷ lệ đi học';
  static const String statsNoData = 'Không có dữ liệu';
  static const String statsWeeklyNoData = 'Không có dữ liệu tuần này';
  static const String statsChange = 'Thay đổi';
  static const String statsMonthPickerHelp = 'CHỌN THÁNG THỐNG KÊ';
  static const String statsWeekPickerHelp = 'CHỌN TUẦN THỐNG KÊ';

  // Parent Attendance History
  static const String attendanceHistoryAbsentList = 'Danh sách vắng mặt';
  static const String attendanceHistoryExcused = 'Có phép';
  static const String attendanceHistoryUnexcused = 'Không phép';
  static const String attendanceHistoryAbsentExcused = 'Vắng có phép';
  static const String attendanceHistoryAbsentUnexcused = 'Vắng không phép';
  static const String attendanceHistoryEmptyTitle = 'Chưa có ngày vắng mặt';
  static const String attendanceHistoryEmptyDesc = 'Bé đi học rất chuyên cần!';
  static const String attendanceAbsent = 'Vắng';
  static const String attendanceStudentList = 'Danh sách học sinh';

  // QR Scanner & Dialogs
  static const String attendanceQrScannerTitle = 'Quét mã điểm danh';
  static const String attendanceQrScannerHint = 'Đưa mã QR của bé vào khung hình';
  static const String attendanceQrScannedSuccess = 'Đã điểm danh';
  static const String attendanceQrScannedError = 'Không thể điểm danh';
  static const String attendanceQrUpdateLate = 'Cập nhật: Vắng → Có mặt  •  ';
  static const String attendanceQrCheckinAtTime = 'Check-in lúc ';
  static const String studentQrErrorLoad = 'Không thể tải mã QR';
  static const String studentQrCodeLabel = 'MÃ ĐIỂM DANH';
  static const String studentQrHint = 'Dùng mã này để điểm danh khi đến trường';

  // ===========================================================================
  // 5. Leave & Medication Requests
  // ===========================================================================
  // Leave Request General
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
  
  // Leave Request Statuses
  static const String leaveStatusAll = 'Tất cả';
  static const String leaveStatusPending = 'Đang chờ';
  static const String leaveStatusApproved = 'Đã duyệt';
  static const String leaveStatusRejected = 'Từ chối';
  static const String leaveStatusCancelled = 'Đã hủy';

  // Leave Request Teacher Management
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
  static const String leaveRequestListTitle = 'Danh sách đơn nghỉ';
  static const String leaveRequestPastDateWarning = 'Không thể gửi đơn xin nghỉ cho các ngày trong quá khứ';
  static const String errorStudentNotFound = 'Không xác định được học sinh';
  static const String leaveRequestSubmitSuccess = 'Đơn xin nghỉ đã được gửi và đang chờ duyệt';
  static const String leaveRequestCancelSuccess = 'Đã hủy đơn thành công';
  static const String leaveRequestUpdateStatusSuccess = 'Đã cập nhật trạng thái đơn nghỉ';

  // Medication Request
  static const String medicationStatusPending = 'Chưa cho uống';
  static const String medicationStatusCompleted = 'Đã cho uống';
  static const String medicationStatusMedical = 'Chuyển Y Tế';

  // ===========================================================================
  // 6. Student Schedule & Activities
  // ===========================================================================
  static const String scheduleTitle = 'Lịch sinh hoạt';
  static const String scheduleSubtitle = 'Theo dõi các hoạt động học tập và vui chơi hàng ngày của bé';
  static const String scheduleDetailTitle = 'Chi tiết lịch sinh hoạt';
  static const String scheduleLessonPrefix = 'Bài học:';
  static const String scheduleObjectivesPrefix = 'Mục tiêu:';
  static const String scheduleContentPrefix = 'Nội dung:';
  static const String scheduleMgmtViewTitle = 'Thời khóa biểu';
  static const String scheduleDetailedListTitle = 'Lịch trình chi tiết';
  static const String scheduleSupplementalSectionTitle = 'Bài soạn bổ sung';
  static const String scheduleNoLessonBadge = 'Chưa có bài soạn';
  static const String schedulePublishedBadge = 'Đã công khai';
  static const String scheduleDraftBadge = 'Đang soạn thảo';
  static const String lessonEditorTitle = 'Soạn bài học';
  static const String lessonSaveConfirmTitle = 'Xác nhận lưu';
  static const String lessonSaveConfirmMessage = 'Bạn có chắc chắn muốn lưu nội dung bài học này không?';
  static const String lessonTitleLabel = 'Tiêu đề bài học';
  static const String lessonTitleHint = 'Ví dụ: Làm quen với chữ cái A, B, C';
  static const String lessonObjectivesLabel = 'Mục tiêu bài học';
  static const String lessonObjectivesHint = 'Trẻ nhận biết và phát âm đúng...';
  static const String lessonContentLabel = 'Nội dung chi tiết';
  static const String lessonContentHint = 'Các bước thực hiện bài dạy...';
  static const String lessonYoutubeLabel = 'Link Video Youtube (Hướng dẫn)';
  static const String lessonYoutubeHint = 'Dán đường dẫn video tại đây...';
  static const String lessonImagesLabel = 'Hình ảnh minh họa';
  static const String lessonDisplaySettingsLabel = 'Cài đặt hiển thị';
  static const String lessonSaveButton = 'Lưu bài học';
  static const String lessonTimeSlotPrefix = 'Khung giờ:';
  static const String lessonSupplementalLabel = 'Bài giảng bổ sung (Tự do)';
  static const String lessonStatusPublishLabel = 'Công khai bài học';
  static const String lessonStatusPublishDesc = 'Phụ huynh sẽ thấy bài học này';
  static const String lessonSaveSuccessMessage = 'Đã lưu nội dung bài học';

  // ===========================================================================
  // 7. Meal Plan & Nutrition
  // ===========================================================================
  static const String mealPlanTitle = 'Thực đơn';
  static const String mealPlanSubtitle = 'Thực đơn dinh dưỡng và các món ăn trong tuần của bé';
  static const String mealPlanDetailTitle = 'Chi tiết thực đơn';
  static const String mealBreakfast = 'Bữa sáng';
  static const String mealLunch = 'Bữa trưa';
  static const String mealSnack = 'Bữa xế';
  static const String mealNotUpdated = 'Chưa cập nhật thực đơn';
  static const String mealEmptyTitle = 'Chưa có thực đơn tuần này';
  static const String mealEmptyDesc = 'Vui lòng quay lại sau';

  // ===========================================================================
  // 8. Health & Medical
  // ===========================================================================
  static const String healthTitle = 'Sức khỏe & Phát triển';
  static const String healthSubtitle = 'Theo dõi các chỉ số phát triển chiều cao, cân nặng của bé';
  static const String healthTeacherSubtitle = 'Cập nhật và theo dõi chỉ số phát triển của học sinh trong lớp';
  static const String healthLatestMeasurementPrefix = 'Lần đo gần nhất — ';
  static const String labelHeight = 'Chiều cao';
  static const String labelWeight = 'Cân nặng';
  static const String labelBmi = 'BMI';
  static const String healthGrowthChart = 'Biểu đồ tăng trưởng';
  static const String healthHistoryTitle = 'Lịch sử đo lường';
  static const String healthMissingInfoWarning = 'Cần cập nhật Ngày sinh và Giới tính để đối chiếu chuẩn WHO.';
  static const String healthNoChartData = 'Chưa có dữ liệu để vẽ biểu đồ';
  static const String healthAgeInMonths = 'Tháng tuổi';
  static const String healthMeasurementIndex = 'Lần đo';
  static const String healthBmiNormal = 'Bình thường';
  static const String healthBmiOverweight = 'Thừa cân';
  static const String healthBmiUnderweight = 'Suy dinh dưỡng';
  static const String healthBmiObese = 'Béo phì';
  static const String healthWhoStandard = 'Chuẩn WHO';
  static const String healthHighThreshold = 'Ngưỡng cao';
  static const String healthLowThreshold = 'Ngưỡng thấp';
  static const String healthHeightCm = 'Chiều cao (cm)';
  static const String healthWeightKg = 'Cân nặng (kg)';
  static const String healthChildLabel = 'Của bé';
  static const String healthClassEmptyTitle = 'Lớp học chưa có học sinh';
  static const String healthNoStudentMatch = 'Không tìm thấy học sinh nào khớp với từ khóa';
  static const String healthClassEmptyDesc = 'Danh sách học sinh của lớp học hiện tại đang trống.';
  static const String healthSaveRecordButton = 'Lưu hồ sơ sức khỏe';
  static const String healthHeaderStudent = 'HỌC SINH';
  static const String healthHeaderHeight = 'CAO (M)';
  static const String healthHeaderWeight = 'NẶNG (KG)';
  static const String healthHeaderBmi = 'BMI / PHÂN LOẠI';
  static const String healthMonthPickerHelp = 'CHỌN THÁNG ĐO';
  static const String errorNoClassAssigned = 'Tài khoản chưa được gán lớp học';
  static const String healthErrorEmptyRow = 'Vui lòng nhập đầy đủ chiều cao và cân nặng cho học sinh';
  static const String healthErrorInvalidNumberPrefix = 'Chiều cao và cân nặng của';
  static const String healthErrorInvalidNumberSuffix = 'phải là số hợp lệ';
  static const String healthErrorNegativeNumberSuffix = 'phải lớn hơn 0';
  static const String healthErrorNoDataToSave = 'Chưa có dữ liệu nào để lưu';
  static const String healthSaveSuccessPrefix = 'Đã lưu';
  static const String healthSaveSuccessSuffix = 'hồ sơ sức khỏe';

  // ===========================================================================
  // 9. Student Guardians & Parents
  // ===========================================================================
  static const String guardianSectionTitle = 'Người giám hộ';
  static const String guardianAddButton = 'Thêm người giám hộ';
  static const String guardianEditTitle = 'Chỉnh sửa người giám hộ';
  static const String guardianDeleteConfirm = 'Bạn có chắc chắn muốn xóa người giám hộ này không?';
  static const String guardianNameLabel = 'Họ và tên người giám hộ';
  static const String guardianNameEmpty = 'Vui lòng nhập họ và tên';
  static const String guardianPhoneLabel = 'Số điện thoại liên hệ';
  static const String guardianPhoneEmpty = 'Vui lòng nhập số điện thoại';
  static const String guardianPhoneInvalid = 'Số điện thoại không hợp lệ (phải gồm 10 chữ số)';
  static const String guardianRelationshipLabel = 'Mối quan hệ';
  static const String guardianRelationshipEmpty = 'Vui lòng chọn mối quan hệ';

  // Student Profile Detail
  static const String studentProfileDetailTitle = 'Hồ sơ chi tiết';
  static const String studentProfileChangeAvatarPicker = 'Thay đổi ảnh đại diện của bé';
  static const String studentProfilePersonalInfo = 'Thông tin cá nhân';
  static const String studentProfileBirthday = 'Ngày sinh';
  static const String studentProfileGender = 'Giới tính';
  static const String studentProfileId = 'Mã học sinh';
  static const String studentProfileLatestGrowth = 'Chỉ số phát triển gần nhất';
  static const String studentProfileUpdatedDate = 'Cập nhật ngày:';
  static const String studentProfileHeight = 'Chiều cao';
  static const String studentProfileWeight = 'Cân nặng';
  static const String studentProfileFamilyContact = 'Liên hệ gia đình';
  static const String studentProfileParentManager = 'Phụ huynh quản lý';
  static const String studentProfileEmailContact = 'Email liên hệ';
  static const String studentProfileNoGuardians = 'Chưa có người giám hộ nào được thêm';
  static const String studentProfileCallError = 'Không thể thực hiện cuộc gọi đến số';
  static const String studentProfileErrorLoadingHealth = 'Không thể tải thông tin sức khỏe của bé';
  static const String studentProfileNotFound = 'Không tìm thấy thông tin học sinh';
  static const String studentProfileLabelBoy = 'Nam';
  static const String studentProfileLabelGirl = 'Nữ';

  // ===========================================================================
  // 10. Profile & Settings
  // ===========================================================================
  static const String profileInfoTitle = 'Thông tin tài khoản';
  static const String profileFullName = 'Họ và tên';
  static const String profileEmail = 'Email';
  static const String profilePhone = 'Số điện thoại';
  static const String profileClassroom = 'Phụ trách lớp';
  static const String profileUnassignedClass = 'Chưa phân công';
  static const String profileAppInfo = 'Thông tin ứng dụng';
  static const String profileContactSchool = 'Liên hệ nhà trường';
  static const String profileSupportTeacher = 'Hotline hỗ trợ giáo viên';
  static const String profileSupportParent = 'Hotline hỗ trợ phụ huynh';
  static const String profileSchoolHotlineInfo = 'Hotline nhà trường: 1900 1234';
  static const String profileTermsOfUse = 'Điều khoản sử dụng';
  static const String profileTermsDesc = 'Các quy định chính sách của hệ thống';
  static const String profileVersionInfo = 'Hệ thống Quản lý Mầm non v1.0.0';
  static const String profileChildrenListTitle = 'Hồ sơ của bé';
  static const String profileUnassignedChildClass = 'Chưa phân lớp';
  static const String profileChangeAvatarTitle = 'Thay đổi ảnh đại diện';
  static const String profileChangeAvatarSuccess = 'Cập nhật ảnh đại diện thành công';
  static const String profileChangeAvatarErrorUpload = 'Không nhận được URL ảnh đại diện sau khi tải lên.';
  static const String profileLabelLogout = 'Đăng xuất';
  static const String profileConfirmLogoutMessage = 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này không?';
  static const String profileUnassignedName = 'Chưa cập nhật tên';
  static const String labelProfile = 'Hồ sơ';
  static const String labelGreeting = 'Xin chào,';

  // ===========================================================================
  // 11. Notifications
  // ===========================================================================
  static const String notificationTitle = 'Thông báo';
  static const String notificationEmpty = 'Bạn không có thông báo nào mới.';
  static const String notificationMarkAllRead = 'Đánh dấu đã đọc tất cả';

  // ===========================================================================
  // 12. Common UI & Dialog Labels
  // ===========================================================================
  // Dialog Titles & Buttons
  static const String dialogConfirmTitle = 'Xác nhận';
  static const String dialogWarningTitle = 'Cảnh báo';
  static const String dialogExitTitle = 'Chưa lưu thay đổi';
  static const String dialogExitMessage = 'Dữ liệu bạn vừa thay đổi sẽ không được lưu lại. Bạn có chắc chắn muốn thoát?';
  static const String dialogSaveMessage = 'Bạn có chắc chắn muốn lưu lại các thay đổi này không?';
  static const String dialogAgree = 'Đồng ý';
  static const String dialogCancel = 'Hủy bỏ';

  // Quick Utility Labels
  static const String editLabel = 'Sửa';
  static const String deleteLabel = 'Xóa';
  static const String unknownLabel = 'Không rõ';
  static const String classLabel = 'Lớp:';
  static const String noClassAssigned = 'Chưa gán';
  static const String confirmLabel = 'Xác nhận';
  static const String notUpdated = 'Chưa cập nhật';
  static const String labelDone = 'Xong';
  static const String labelClose = 'Đóng';
  static const String labelScanNext = 'Quét tiếp';
  static const String labelRetry = 'Thử lại';
  static const String errorNoResults = 'Không tìm thấy kết quả';
  static const String labelSave = 'LƯU';
  static const String labelSeeAll = 'Xem tất cả';

  // ===========================================================================
  // 13. Validation & State Feedback
  // ===========================================================================
  // Basic Field Validation
  static const String errorEmptyField = 'Vui lòng không để trống';
  static const String errorInvalidEmail = 'Email không hợp lệ';
  static const String errorPasswordLength = 'Mật khẩu ít nhất 6 ký tự';
  static const String errorPasswordMatch = 'Mật khẩu không khớp';

  // Advanced Validation Messages
  static const String errorInputRequired = 'Vui lòng nhập';
  static const String errorMinLengthSuffix = 'phải có ít nhất';
  static const String errorMinLengthChars = 'ký tự';
  static const String errorSelectRequired = 'Vui lòng chọn';
  static const String errorEmptyLeaveReason = 'Vui lòng nhập lý do xin nghỉ';
  static const String errorEmptyLessonTitle = 'Vui lòng nhập tiêu đề bài học';

  // Standardized State Messages
  static const String successTitle = 'Thành công';
  static const String errorTitle = 'Lỗi';
  static const String successUpdatePassword = 'Mật khẩu đã được đổi thành công. Vui lòng đăng nhập lại.';
  static const String errorUpdatePassword = 'Không thể cập nhật mật khẩu. Vui lòng thử lại.';
  static const String errorEmailNotFound = 'Không tìm thấy tài khoản với email này';
  static const String errorInvalidOtp = 'Mã xác thực không đúng hoặc đã hết hạn';
  static const String errorLoginFailed = 'Email hoặc mật khẩu không chính xác';

  // UI/UX Status & Network States
  static const String loadingData = 'Đang tải dữ liệu...';
  static const String errorNoStudentSelected = 'Vui lòng chọn bé để sử dụng chức năng này';
  static const String errorStudentNoClass = 'Bé hiện tại chưa được xếp lớp học';
  static const String errorRequiredText = 'Vui lòng điền thông tin';
  static const String errorInvalidYoutube = 'Đường dẫn YouTube không hợp lệ';
  static const String errorDateRangeInvalid = 'Dải ngày chọn không hợp lệ';
  static const String errorStartDateAfterEnd = 'Ngày bắt đầu không được sau ngày kết thúc';
  static const String errorGeneric = 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.';
  static const String errorNetwork = 'Kết nối mạng không ổn định. Vui lòng kiểm tra lại mạng.';
  static const String errorTimeout = 'Yêu cầu kết nối quá hạn. Vui lòng thử lại sau.';
  static const String errorUnauthorized = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
  static const String emptyScheduleParentTitle = 'Không có lịch học';
  static const String emptyScheduleParentDesc = 'Hiện tại chưa có lịch sinh hoạt hay bài học nào được xếp cho ngày này.';
  static const String emptyScheduleTeacherTitle = 'Trống lịch trình';
  static const String emptyScheduleTeacherDesc = 'Chưa có hoạt động hay bài soạn nào được chuẩn bị cho ngày này.';
}

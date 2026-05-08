class AppDatabase {
  AppDatabase._();

  // --- Status (Common) ---
  static const String pending = 'PENDING';
  static const String approved = 'APPROVED';
  static const String rejected = 'REJECTED';
  static const String cancelled = 'CANCELLED';

  // --- Attendance Status ---
  static const String statusPresent = 'PRESENT';
  static const String statusAbsentUnexcused = 'ABSENT_UNEXCUSED';
  static const String statusAbsentExcused = 'ABSENT_EXCUSED';
  
  // --- Lesson Status ---
  static const String statusDraft = 'draft';
  static const String statusPublished = 'published';

  // --- Attendance Method ---
  static const String methodManual = 'MANUAL';
  static const String methodQr = 'QR';

  // --- Tables ---
  static const String tableUsers = 'users';
  static const String tableStudents = 'students';
  static const String tableAttendance = 'attendance';
  static const String tableClassrooms = 'classrooms';
  static const String tableLeaveRequests = 'leave_requests';
  static const String tableNotifications = 'notifications';
  static const String tableQrTokens = 'qr_tokens';
  static const String tableUserRoles = 'user_roles';
  static const String tableRoles = 'roles';
  static const String tableGrades = 'grades';          
  static const String tableHealthRecords = 'health_records'; 
  static const String tableMealPlans = 'meal_plans';  
  static const String tableSchedules = 'schedules';
  static const String tableLessons = 'lessons';   

  // --- Common Columns ---
  static const String colId = 'id';
  static const String colUserId = 'user_id';
  static const String colName = 'name';
  static const String colAvatarUrl = 'avatar_url';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colStatus = 'status';
  static const String colDate = 'date';
  static const String colTeacherId = 'teacher_id';      
  static const String colNote = 'note';
  static const String colScheduleId = 'schedule_id';

  static const String colCode = 'code';

  // --- Students Columns ---
  static const String colClassroomId = 'classroom_id';
  static const String colParentId = 'parent_id';
  static const String colBirthday = 'dob';     
  static const String colGender = 'gender';         

  // --- Attendance Columns ---
  static const String colStudentId = 'student_id';
  static const String colCheckinTime = 'checkin_time';
  static const String colMethod = 'method';

  // --- Leave Requests Columns ---
  static const String colStartDate = 'start_date';
  static const String colEndDate = 'end_date';
  static const String colReason = 'reason';
  static const String colCancelReason = 'cancel_reason';
  static const String colApprovedBy = 'approved_by';
  static const String colApprovedAt = 'approved_at';
  static const String colImages = 'images';

  // --- Notifications Columns ---
  static const String colTitle = 'title';
  static const String colContent = 'content';
  static const String colIsRead = 'is_read';
  static const String colType = 'type';
  static const String colReferenceId = 'reference_id';

  // Activity Logs
  static const String tableActivityLogs = 'activity_logs';
  static const String tableActivityImages = 'activity_images';
  static const String tableActivityLikes = 'activity_likes';
  static const String tableActivityComments = 'activity_comments';
  
  static const String colActivityId = 'activity_id';
  static const String colActivityLogId = 'activity_log_id';
  static const String colImageUrl = 'image_url';

  // --- Health Records Columns  ---
  static const String colHeight = 'height';
  static const String colWeight = 'weight';
  static const String colBmi = 'bmi';

  // --- Meal Plans Columns ---
  static const String colGradeId = 'grade_id';
  static const String colDayOfWeek = 'day_of_week';
  static const String colBreakfast = 'breakfast';
  static const String colLunch = 'lunch';
  static const String colSnack = 'snack';

  // --- Meal Plans Additional Columns ---
  static const String colBreakfastImg = 'breakfast_img';
  static const String colLunchImg = 'lunch_img';
  static const String colSnackImg = 'snack_img';
  static const String colBreakfastTime = 'breakfast_time';
  static const String colLunchTime = 'lunch_time';
  static const String colSnackTime = 'snack_time';

  // --- Schedules Columns ---
  static const String colStartTime = 'start_time';
  static const String colEndTime = 'end_time';
  static const String colActivityName = 'activity_name';
  static const String colIsLessonSlot = 'is_lesson_slot';

  // --- Lessons Columns ---
  static const String colObjectives = 'objectives';
  static const String colLessonImages = 'images';
  static const String colYoutubeUrl = 'youtube_url';
  static const String colAttachmentUrl = 'attachment_url';
  static const String colPreparation = 'preparation';
  static const String colProcedures = 'procedures';
}
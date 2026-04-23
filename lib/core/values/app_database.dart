class AppDatabase {
  AppDatabase._();

  
  // Status
  static const String pending = 'PENDING';
  static const String approved = 'APPROVED';
  static const String rejected = 'REJECTED';
  static const String cancelled = 'CANCELLED';
  static const String completed = 'APPROVED';

  // Attendance Status
  static const String statusPresent = 'PRESENT';
  static const String statusAbsentUnexcused = 'ABSENT_UNEXCUSED';
  static const String statusAbsentExcused = 'ABSENT_EXCUSED';

  // Attendance Method
  static const String methodManual = 'MANUAL';
  static const String methodQr = 'QR';

  // Tables
  static const String tableUsers = 'users';
  static const String tableStudents = 'students';
  static const String tableAttendance = 'attendance';
  static const String tableClassrooms = 'classrooms';
  static const String tableLeaveRequests = 'leave_requests';
  static const String tableNotifications = 'notifications';
  static const String tableQrTokens = 'qr_tokens';
  static const String tableUserRoles = 'user_roles';
  static const String tableRoles = 'roles';
  static const String colTeacherId = 'teacher_id';

  // Common Columns
  static const String colId = 'id';
  static const String colUserId = 'user_id';
  static const String colName = 'name';
  static const String colAvatarUrl = 'avatar_url';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colStatus = 'status';

  // Students Columns
  static const String colClassroomId = 'classroom_id';
  static const String colParentId = 'parent_id';

  // Attendance Columns
  static const String colStudentId = 'student_id';
  static const String colDate = 'date';
  static const String colCheckinTime = 'checkin_time';
  static const String colMethod = 'method';
  static const String colNote = 'note';

  // Leave Requests Columns
  static const String colStartDate = 'start_date';
  static const String colEndDate = 'end_date';
  static const String colReason = 'reason';
  static const String colCancelReason = 'cancel_reason';
  static const String colApprovedBy = 'approved_by';
  static const String colApprovedAt = 'approved_at';
  static const String colEvidenceUrl = 'evidence_url';

  // Medication Requests Columns
  static const String tableMedicationRequests = 'medication_requests';
  static const String colMedicineName = 'medicine_name';
  static const String colDosage = 'dosage';
  static const String colTime = 'time';
  static const String colPrescriptionImage = 'prescription_image';


  // Notifications Columns
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
}
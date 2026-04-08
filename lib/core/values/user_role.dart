class UserRole {
  UserRole._();

  static const String teacher = 'TEACHER';
  static const String parent = 'PARENT';
  static const String admin = 'ADMIN';

  // Helper to check role
  static bool isTeacher(String? role) => role == teacher;
  static bool isParent(String? role) => role == parent;
}

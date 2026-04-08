class AppDatabase {
  AppDatabase._();

  // Tables
  static const String tableUserRoles = 'user_roles';
  static const String tableRoles = 'roles';
  static const String tableProfile = 'profiles';
  static const String tableAttendance = 'attendances';
  static const String tableClass = 'classes';

  // Columns
  static const String colId = 'id';
  static const String colUserId = 'user_id';
  static const String colRoleId = 'role_id';
  static const String colName = 'name';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
}

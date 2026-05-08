import 'package:intl/intl.dart';

class DateHelper {
  /// Parse chuỗi ngày tháng từ server và đảm bảo nó được hiểu là UTC.
  /// Dùng cho các trường BẮT BUỘC (không được null).
  /// Nếu đầu vào null, trả về DateTime.now() để tránh crash app.
  static DateTime parseUtc(dynamic date) {
    if (date == null) return DateTime.now();
    
    DateTime dt;
    if (date is DateTime) {
      dt = date;
    } else {
      dt = DateTime.parse(date.toString());
    }

    if (!dt.isUtc) {
      dt = DateTime.utc(
        dt.year, dt.month, dt.day,
        dt.hour, dt.minute, dt.second,
        dt.millisecond, dt.microsecond,
      );
    }
    
    return dt;
  }

  /// Parse chuỗi ngày tháng từ server và đảm bảo nó được hiểu là UTC.
  /// Dùng cho các trường KHÔNG BẮT BUỘC (có thể null).
  static DateTime? parseUtcNullable(dynamic date) {
    if (date == null) return null;
    return parseUtc(date);
  }

  /// Định dạng hiển thị ngày tháng năm
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date.toLocal());
  }

  /// Định dạng hiển thị giờ phút
  static String formatTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('HH:mm').format(date.toLocal());
  }

  /// Định dạng hiển thị đầy đủ: Thứ, ngày dd/MM/yyyy
  static String formatFullDate(DateTime date) {
    final days = {
      DateTime.monday: 'Thứ Hai',
      DateTime.tuesday: 'Thứ Ba',
      DateTime.wednesday: 'Thứ Tư',
      DateTime.thursday: 'Thứ Năm',
      DateTime.friday: 'Thứ Sáu',
      DateTime.saturday: 'Thứ Bảy',
      DateTime.sunday: 'Chủ Nhật',
    };
    final weekday = days[date.weekday];
    return '$weekday, ngày ${DateFormat('dd/MM/yyyy').format(date)}';
  }
}

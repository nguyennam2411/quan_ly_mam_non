/// Dữ liệu chuẩn tăng trưởng WHO cho trẻ em từ 0-60 tháng tuổi.
/// Nguồn: WHO Child Growth Standards (2006)
/// Key: tháng tuổi (0-60)
/// Giá trị: {median, sd_plus2, sd_minus2}
class WhoGrowthData {
  WhoGrowthData._();

  // ─── CHIỀU CAO (cm) ───────────────────────────────────────────────────────

  /// Chiều cao chuẩn cho Bé Trai (cm)
  static const Map<int, Map<String, double>> heightBoys = {
    0: {'median': 49.9, 'plus2': 53.4, 'minus2': 46.3},
    3: {'median': 61.4, 'plus2': 65.5, 'minus2': 57.3},
    6: {'median': 67.6, 'plus2': 71.9, 'minus2': 63.3},
    9: {'median': 72.3, 'plus2': 76.9, 'minus2': 67.7},
    12: {'median': 75.7, 'plus2': 80.5, 'minus2': 71.0},
    15: {'median': 79.1, 'plus2': 84.2, 'minus2': 74.1},
    18: {'median': 82.3, 'plus2': 87.7, 'minus2': 77.0},
    21: {'median': 85.1, 'plus2': 90.8, 'minus2': 79.4},
    24: {'median': 87.8, 'plus2': 93.8, 'minus2': 81.8},
    30: {'median': 92.5, 'plus2': 99.0, 'minus2': 86.1},
    36: {'median': 96.5, 'plus2': 103.3, 'minus2': 89.7},
    42: {'median': 100.3, 'plus2': 107.4, 'minus2': 93.2},
    48: {'median': 103.3, 'plus2': 110.9, 'minus2': 95.8},
    54: {'median': 107.0, 'plus2': 114.9, 'minus2': 99.2},
    60: {'median': 110.0, 'plus2': 118.4, 'minus2': 101.7},
  };

  /// Chiều cao chuẩn cho Bé Gái (cm)
  static const Map<int, Map<String, double>> heightGirls = {
    0: {'median': 49.1, 'plus2': 52.4, 'minus2': 45.6},
    3: {'median': 59.8, 'plus2': 63.9, 'minus2': 55.6},
    6: {'median': 65.7, 'plus2': 70.0, 'minus2': 61.2},
    9: {'median': 70.1, 'plus2': 74.7, 'minus2': 65.3},
    12: {'median': 74.0, 'plus2': 78.9, 'minus2': 69.0},
    15: {'median': 77.5, 'plus2': 82.7, 'minus2': 72.3},
    18: {'median': 80.7, 'plus2': 86.2, 'minus2': 75.2},
    21: {'median': 83.7, 'plus2': 89.5, 'minus2': 77.9},
    24: {'median': 86.4, 'plus2': 92.5, 'minus2': 80.3},
    30: {'median': 91.4, 'plus2': 98.1, 'minus2': 84.8},
    36: {'median': 95.1, 'plus2': 102.2, 'minus2': 88.1},
    42: {'median': 99.0, 'plus2': 106.5, 'minus2': 91.5},
    48: {'median': 102.7, 'plus2': 110.6, 'minus2': 94.9},
    54: {'median': 106.2, 'plus2': 114.6, 'minus2': 97.9},
    60: {'median': 109.4, 'plus2': 118.3, 'minus2': 100.6},
  };

  // ─── CÂN NẶNG (kg) ───────────────────────────────────────────────────────

  /// Cân nặng chuẩn cho Bé Trai (kg)
  static const Map<int, Map<String, double>> weightBoys = {
    0: {'median': 3.3, 'plus2': 4.4, 'minus2': 2.5},
    3: {'median': 5.9, 'plus2': 7.4, 'minus2': 4.6},
    6: {'median': 7.5, 'plus2': 9.2, 'minus2': 6.0},
    9: {'median': 8.9, 'plus2': 10.9, 'minus2': 7.1},
    12: {'median': 9.6, 'plus2': 11.8, 'minus2': 7.7},
    15: {'median': 10.3, 'plus2': 12.7, 'minus2': 8.2},
    18: {'median': 10.9, 'plus2': 13.5, 'minus2': 8.6},
    21: {'median': 11.5, 'plus2': 14.3, 'minus2': 9.0},
    24: {'median': 12.2, 'plus2': 15.3, 'minus2': 9.7},
    30: {'median': 13.3, 'plus2': 16.9, 'minus2': 10.5},
    36: {'median': 14.3, 'plus2': 18.3, 'minus2': 11.3},
    42: {'median': 15.3, 'plus2': 19.7, 'minus2': 12.1},
    48: {'median': 16.3, 'plus2': 21.2, 'minus2': 12.8},
    54: {'median': 17.3, 'plus2': 22.8, 'minus2': 13.5},
    60: {'median': 18.3, 'plus2': 24.2, 'minus2': 14.1},
  };

  /// Cân nặng chuẩn cho Bé Gái (kg)
  static const Map<int, Map<String, double>> weightGirls = {
    0: {'median': 3.2, 'plus2': 4.2, 'minus2': 2.4},
    3: {'median': 5.5, 'plus2': 7.0, 'minus2': 4.3},
    6: {'median': 7.0, 'plus2': 8.8, 'minus2': 5.5},
    9: {'median': 8.2, 'plus2': 10.4, 'minus2': 6.4},
    12: {'median': 8.9, 'plus2': 11.2, 'minus2': 6.9},
    15: {'median': 9.6, 'plus2': 12.1, 'minus2': 7.5},
    18: {'median': 10.2, 'plus2': 13.0, 'minus2': 7.9},
    21: {'median': 10.9, 'plus2': 13.9, 'minus2': 8.3},
    24: {'median': 11.5, 'plus2': 14.8, 'minus2': 8.8},
    30: {'median': 12.7, 'plus2': 16.5, 'minus2': 9.7},
    36: {'median': 13.9, 'plus2': 18.2, 'minus2': 10.5},
    42: {'median': 14.9, 'plus2': 19.6, 'minus2': 11.3},
    48: {'median': 16.0, 'plus2': 21.1, 'minus2': 12.1},
    54: {'median': 17.0, 'plus2': 22.7, 'minus2': 12.8},
    60: {'median': 18.2, 'plus2': 24.5, 'minus2': 13.7},
  };

  /// Lấy danh sách điểm dữ liệu WHO cho biểu đồ đường (chiều cao hoặc cân nặng).
  /// [isBoy]: true = bé trai, false = bé gái
  /// [isHeight]: true = chiều cao, false = cân nặng
  static List<Map<String, double>> getChartPoints({
    required bool isBoy,
    required bool isHeight,
  }) {
    final data = isHeight
        ? (isBoy ? heightBoys : heightGirls)
        : (isBoy ? weightBoys : weightGirls);

    final sortedKeys = data.keys.toList()..sort();
    return sortedKeys
        .map((month) => {
              'month': month.toDouble(),
              'median': data[month]!['median']!,
              'plus2': data[month]!['plus2']!,
              'minus2': data[month]!['minus2']!,
            })
        .toList();
  }
}

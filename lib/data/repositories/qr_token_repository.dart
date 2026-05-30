import 'package:uuid/uuid.dart';
import '../models/qr_token_model.dart';
import '../providers/qr_token_provider.dart';

class QrRepository {
  final QrTokenProvider _provider = QrTokenProvider();
  final _uuid = const Uuid();

  Future<QrTokenModel> getOrGenerateQrToken(String studentId) async {
    // 1. Kiểm tra xem bé đã có mã trong bảng qr_tokens chưa
    final existingData = await _provider.getQrByStudentId(studentId);

    if (existingData != null) {
      // Nếu có rồi, trả về Model luôn
      return QrTokenModel.fromJson(existingData);
    } else {
      // 2. Nếu chưa có, tiến hành sinh mã mới (Fixed Code)
      // dùng UUID v4 để làm mã cố định 
      final newCode = _uuid.v4(); 
      
      final newToken = QrTokenModel(
        studentId: studentId,
        code: newCode,
      );

      final createdData = await _provider.createQrToken(newToken.toJson());
      return QrTokenModel.fromJson(createdData);
    }
  }
}
import '../providers/profile_provider.dart';

class ProfileRepository {
  final ProfileProvider _provider;

  ProfileRepository(this._provider);

  /// Cập nhật ảnh đại diện của người dùng
  Future<void> updateAvatar(String userId, String imageUrl) async {
    await _provider.updateAvatar(userId, imageUrl);
  }
}

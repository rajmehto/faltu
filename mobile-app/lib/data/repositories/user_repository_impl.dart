import '../../core/network/api_response.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl {
  final UserRemoteDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  Future<UserModel> getProfile() async => _dataSource.getProfile();

  Future<UserModel> updateProfile({
    String? displayName,
    String? bio,
    String? gender,
    String? country,
    String? city,
    DateTime? birthday,
  }) async {
    return _dataSource.updateProfile(
      displayName: displayName,
      bio: bio,
      gender: gender,
      country: country,
      city: city,
      birthday: birthday,
    );
  }

  Future<UserModel> getUserById(String userId) async =>
      _dataSource.getUserById(userId);

  Future<void> followUser(String userId) async => _dataSource.followUser(userId);

  Future<void> unfollowUser(String userId) async => _dataSource.unfollowUser(userId);

  Future<bool> isFollowing(String userId) async => _dataSource.isFollowing(userId);

  Future<void> blockUser(String userId) async => _dataSource.blockUser(userId);

  Future<void> unblockUser(String userId) async => _dataSource.unblockUser(userId);

  Future<void> reportUser(String userId, {
    required String reason,
    String? description,
  }) async {
    await _dataSource.reportUser(userId, reason: reason, description: description);
  }

  Future<PaginatedResponse<UserModel>> getFollowers(String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return _dataSource.getFollowers(userId, page: page, pageSize: pageSize);
  }

  Future<PaginatedResponse<UserModel>> getFollowing(String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return _dataSource.getFollowing(userId, page: page, pageSize: pageSize);
  }

  Future<PaginatedResponse<UserModel>> getSuggestedUsers({
    int page = 1,
    int pageSize = 20,
  }) async {
    return _dataSource.getSuggestedUsers(page: page, pageSize: pageSize);
  }

  Future<PaginatedResponse<UserModel>> searchUsers({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    return _dataSource.searchUsers(query: query, page: page, pageSize: pageSize);
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async =>
      _dataSource.updateSettings(settings);

  Future<void> updatePrivacySettings(Map<String, dynamic> settings) async =>
      _dataSource.updatePrivacySettings(settings);
}

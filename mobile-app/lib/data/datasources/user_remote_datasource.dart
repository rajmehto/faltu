import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../models/user_model.dart';

class UserRemoteDataSource {
  final ApiClient _client;

  UserRemoteDataSource(this._client);

  Future<UserModel> getProfile() async {
    final response = await _client.get<UserModel>(
      '/users/profile',
      fromJson: (data) => UserModel.fromJson(data),
    );
    return response.data!;
  }

  Future<UserModel> updateProfile({
    String? displayName,
    String? bio,
    String? gender,
    String? country,
    String? city,
    DateTime? birthday,
  }) async {
    final response = await _client.put<UserModel>(
      '/users/profile',
      data: {
        if (displayName != null) 'displayName': displayName,
        if (bio != null) 'bio': bio,
        if (gender != null) 'gender': gender,
        if (country != null) 'country': country,
        if (city != null) 'city': city,
        if (birthday != null) 'birthday': birthday.toIso8601String(),
      },
      fromJson: (data) => UserModel.fromJson(data),
    );
    return response.data!;
  }

  Future<UserModel> getUserById(String userId) async {
    final response = await _client.get<UserModel>(
      '/users/$userId',
      fromJson: (data) => UserModel.fromJson(data),
    );
    return response.data!;
  }

  Future<String?> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath, filename: 'avatar.jpg'),
    });
    final response = await _client.upload<Map<String, dynamic>>(
      '/users/avatar',
      formData: formData,
    );
    return response.data?['avatarUrl'];
  }

  Future<String?> uploadCoverImage(String filePath) async {
    final formData = FormData.fromMap({
      'cover': await MultipartFile.fromFile(filePath, filename: 'cover.jpg'),
    });
    final response = await _client.upload<Map<String, dynamic>>(
      '/users/cover',
      formData: formData,
    );
    return response.data?['coverUrl'];
  }

  Future<void> followUser(String userId) async {
    await _client.post('/users/$userId/follow');
  }

  Future<void> unfollowUser(String userId) async {
    await _client.delete('/users/$userId/follow');
  }

  Future<bool> isFollowing(String userId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/users/$userId/following-status',
    );
    return response.data?['isFollowing'] ?? false;
  }

  Future<void> blockUser(String userId) async {
    await _client.post('/users/$userId/block');
  }

  Future<void> unblockUser(String userId) async {
    await _client.delete('/users/$userId/block');
  }

  Future<void> reportUser(String userId, {
    required String reason,
    String? description,
  }) async {
    await _client.post('/users/$userId/report', data: {
      'reason': reason,
      if (description != null) 'description': description,
    });
  }

  Future<PaginatedResponse<UserModel>> getFollowers(String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get<PaginatedResponse<UserModel>>(
      '/users/$userId/followers',
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => UserModel.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<PaginatedResponse<UserModel>> getFollowing(String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get<PaginatedResponse<UserModel>>(
      '/users/$userId/following',
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => UserModel.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<PaginatedResponse<UserModel>> getSuggestedUsers({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get<PaginatedResponse<UserModel>>(
      '/users/suggestions',
      queryParameters: {'page': page, 'pageSize': pageSize},
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => UserModel.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<PaginatedResponse<UserModel>> searchUsers({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.get<PaginatedResponse<UserModel>>(
      '/users/search',
      queryParameters: {'q': query, 'page': page, 'pageSize': pageSize},
      fromJson: (data) => PaginatedResponse.fromJson(
        data,
        (item) => UserModel.fromJson(item),
      ),
    );
    return response.data!;
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    await _client.put('/users/settings', data: settings);
  }

  Future<void> updatePrivacySettings(Map<String, dynamic> settings) async {
    await _client.put('/users/privacy', data: settings);
  }

  Future<void> deleteAccount(String reason) async {
    await _client.delete('/users/account', data: {'reason': reason});
  }
}

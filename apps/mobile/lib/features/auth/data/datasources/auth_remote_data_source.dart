import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/user_model.dart';

/// Result of a successful login (user + access token).
class LoginResult {
  final UserModel user;
  final String accessToken;

  const LoginResult({required this.user, required this.accessToken});
}

abstract class AuthRemoteDataSource {
  /// Login with username or email and password. Returns user and access token.
  Future<LoginResult> login({
    required String usernameOrEmail,
    required String password,
  });

  /// Register via POST /api/v1/register (email, username, password). Returns created user.
  Future<UserModel> register({
    required String email,
    required String username,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._apiClient, this._dio);

  @override
  Future<LoginResult> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) throw NetworkException();

      final body =
          'username=${Uri.encodeComponent(usernameOrEmail)}&password=${Uri.encodeComponent(password)}';
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/login',
        data: body,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        final msg = _messageFromResponse(response.data);
        throw UnauthorizedException(message: msg.isNotEmpty ? msg : 'Invalid credentials');
      }

      final accessToken = response.data!['access_token'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        throw ServerException(message: 'No token in response');
      }

      _apiClient.setToken(accessToken);
      final userResult = await _apiClient.get('/api/v1/user/me/');

      return userResult.fold(
        (failure) => throw ServerException(message: failure.message),
        (data) {
          final user = UserModel.fromApiJson(data as Map<String, dynamic>);
          return LoginResult(user: user, accessToken: accessToken);
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final msg = _messageFromResponse(e.response?.data);
        throw UnauthorizedException(
          message: msg.isEmpty ? 'Invalid credentials' : msg,
        );
      }
      throw _handleException(ServerException(message: e.message ?? 'Network error'));
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) throw NetworkException();

      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/register',
        data: {'email': email, 'username': username, 'password': password},
        options: Options(validateStatus: (status) => status != null && status < 500),
      );

      if (response.statusCode != 201 || response.data == null) {
        final msg = _messageFromResponse(response.data);
        throw BadRequestException(message: msg.isNotEmpty ? msg : 'Registration failed');
      }

      return UserModel.fromApiJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) {
        final msg = _messageFromResponse(e.response?.data);
        throw BadRequestException(message: msg.isNotEmpty ? msg : 'Validation failed');
      }
      throw _handleException(ServerException(message: e.message ?? 'Network error'));
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  static String _messageFromResponse(dynamic data) {
    if (data == null || data is! Map) return '';
    final detail = data['detail'];
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map && first['msg'] != null) return first['msg'].toString();
      return first.toString();
    }
    return (data['message'] ?? '').toString();
  }

  Exception _handleException(Exception e) {
    if (e is NetworkException ||
        e is ServerException ||
        e is UnauthorizedException ||
        e is BadRequestException) {
      return e;
    }
    return ServerException(message: e.toString());
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    ref.watch(apiClientProvider),
    ref.watch(dioProvider),
  );
});

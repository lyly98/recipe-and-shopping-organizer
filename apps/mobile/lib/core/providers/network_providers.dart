import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../network/auth_event_bus.dart';
import '../network/interceptors/retry_interceptor.dart';
import '../constants/app_constants.dart';

part 'network_providers.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio();

  dio.options.baseUrl = AppConstants.apiBaseUrl;
  dio.options.connectTimeout = const Duration(milliseconds: 30000);
  dio.options.receiveTimeout = const Duration(milliseconds: 30000);
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Intercept 401 responses and broadcast an unauthorized event so that
  // AuthNotifier can trigger logout without a circular import dependency.
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) {
        if (e.response?.statusCode == 401) {
          unauthorizedEventController.add(null);
        }
        handler.next(e);
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ),
  );
  dio.interceptors.add(RetryInterceptor(dio: dio));

  return dio;
}

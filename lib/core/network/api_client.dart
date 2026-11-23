import 'package:dio/dio.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';

class ApiClient {
  ApiClient({
    String? baseUrl,
    String Function()? tokenReader,
    String Function()? tenantDomainReader,
    int? Function()? branchIdReader,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
            connectTimeout: AppConfig.connectTimeout,
            receiveTimeout: AppConfig.receiveTimeout,
            headers: <String, dynamic>{
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = tokenReader?.call();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          final domain = tenantDomainReader?.call();
          if (domain != null && domain.isNotEmpty) {
            options.headers['X-Tenant-Domain'] = domain;
          }

          final branchId = branchIdReader?.call();
          if (branchId != null) {
            options.headers['X-Branch-Id'] = branchId.toString();
          }

          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;

  Dio get raw => _dio;
}


import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/app_strings.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/app_navigator.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/login_viewmodel.dart';

final tokenProvider = FutureProvider<String?>((ref) async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'token');
});

class DioClient {
  DioClient._();

  static Dio createDio(List<Interceptor> extraInterceptors) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppStrings.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      _LogInterceptor(),
      ...extraInterceptors,
      _ErrorInterceptor(),
    ]);

    return dio;
  }
}

class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ [${options.method}] ${options.uri}');
    debugPrint('   Body: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('← [${response.statusCode}] ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('✕ [ERROR] ${err.requestOptions.uri} → ${err.message}');
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = switch (err.type) {
      DioExceptionType.connectionTimeout => 'Koneksi timeout, coba lagi',
      DioExceptionType.receiveTimeout => 'Server terlalu lama merespon',
      DioExceptionType.sendTimeout => 'Gagal mengirim data',
      DioExceptionType.connectionError => 'Tidak ada koneksi internet',
      DioExceptionType.badResponse => _handleStatusCode(err.response),
      _ => 'Terjadi kesalahan, coba lagi',
    };

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: message,
        type: err.type,
        response: err.response,
      ),
    );
  }

  String _handleStatusCode(Response? response) {
    return switch (response?.statusCode) {
      400 => response?.data?['message'] ?? 'Request tidak valid',
      401 => response?.data?['message'] ?? 'Username atau password salah',
      403 => response?.data?['message'] ?? 'Akses ditolak',
      404 => response?.data?['message'] ?? 'Data tidak ditemukan',
      413 =>
        response?.data?['message'] ??
            'Ukuran file gambar terlalu besar. Harap kompres gambar Anda.',
      422 => response?.data?['message'] ?? 'Data tidak valid',
      500 => response?.data?['message'] ?? 'Terjadi kesalahan pada server',
      _ => 'Terjadi kesalahan (${response?.statusCode})',
    };
  }
}

class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';

      if (kDebugMode) {
        debugPrint('    Token: Bearer ${token.substring(0, 20)}...');
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isLoginRequest = err.requestOptions.path.contains('login');

    if (err.response?.statusCode == 401 && !isLoginRequest) {
      debugPrint('⚠️ TOKEN EXPIRED — logout & redirect ke login');

      const storage = FlutterSecureStorage();
      await Future.wait([
        storage.delete(key: AppStrings.tokenKey),
        storage.delete(key: AppStrings.userIdKey),
        storage.delete(key: AppStrings.userNameKey),
        storage.delete(key: AppStrings.userEmailKey),
        storage.delete(key: AppStrings.userRoleKey),
      ]);

      _ref.read(loginViewModelProvider.notifier).resetState();

      AppNavigator.goToLogin();

      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: 'Sesi telah berakhir, silakan login kembali',
          type: DioExceptionType.cancel,
          response: err.response,
        ),
      );
      return;
    }

    handler.next(err);
  }
}

final dioProvider = Provider<Dio>(
  (ref) => DioClient.createDio([AuthInterceptor(ref)]),
);

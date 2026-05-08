import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/viewmodels/login_viewmodel.dart';

// Provider token — baca dari secure storage
final tokenProvider = FutureProvider<String?>((ref) async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'token');
});

// Instance Dio terpusat dengan interceptor
class DioClient {
  DioClient._();

  static Dio createDio(List<Interceptor> extraInterceptors) {
    final dio = Dio(
      BaseOptions(
        baseUrl: "https://wirateknik.backendify.my.id/api/v1",
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
      _ErrorInterceptor(),
      ...extraInterceptors, // AuthInterceptor masuk dari sini
    ]);

    return dio;
  }
}

// Log tiap request & response - aktif hanya di debug mode
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

// Konversi semua DioException ke pesan yang user-friendly
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

    // Lempar sebagai exception biasa supaya ViewModel bisa catch
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
      401 => 'Email atau password salah',
      403 => 'Akses ditolak',
      404 => 'Data tidak ditemukan',
      422 => response?.data?['message'] ?? 'Data tidak valid',
      500 => 'Terjadi kesalahan pada server',
      _ => 'Terjadi kesalahan (${response?.statusCode})',
    };
  }
}

// AuthInterceptor menerima ref dengan benar dari dioProvider
class AuthInterceptor extends Interceptor {
  // ignore: unused_field
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Baca token langsung dari secure storage
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
    // Token expired → hapus token & logout otomatis
    if (err.response?.statusCode == 401) {
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'token');

      // Uncomment setelah authViewModelProvider dibuat
      _ref.read(loginViewModelProvider.notifier).logout();
    }
    handler.next(err);
  }
}

// Provider Dio - satu instance untuk semua repository
final dioProvider = Provider<Dio>(
  (ref) => DioClient.createDio([AuthInterceptor(ref)]),
);

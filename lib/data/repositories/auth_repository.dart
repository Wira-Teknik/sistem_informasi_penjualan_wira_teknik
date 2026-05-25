import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/app_strings.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/jwt_utils.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/email_sender_response_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/login_response_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/reset_password_response_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/user_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/verify_code_response_model.dart';

abstract class AuthRepository {
  Future<LoginResponseModel> login(String username, String password);
  Future<LoginResponseModel?> getSavedSession();
  Future<EmailSenderResponseModel> forgotPassword(String email);
  Future<VerifyCodeResponseModel> verifyCode(String email, String otp);
  Future<ResetPasswordResponseModel> resetPassword(
    String confirmPassword,
    String newPassword,
    String token,
  );
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  AuthRepositoryImpl(this._dio);

  @override
  Future<LoginResponseModel> login(String username, String password) async {
    try {
      final response = await _dio.post(
        AppStrings.loginEndpoint,
        data: {'name': username, 'password': password},
      );

      return LoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Login gagal');
    }
  }

  // Baca token + data user yang tersimpan di secure storage
  @override
  Future<LoginResponseModel?> getSavedSession() async {
    try {
      final token = await _storage.read(key: AppStrings.tokenKey);
      final id = await _storage.read(key: AppStrings.userIdKey);
      final name = await _storage.read(key: AppStrings.userNameKey);
      final email = await _storage.read(key: AppStrings.userEmailKey);
      final role = await _storage.read(key: AppStrings.userRoleKey);

      if (token == null ||
          id == null ||
          name == null ||
          email == null ||
          role == null) {
        return null;
      }

      // ← Cek apakah token sudah expired
      if (JwtUtils.isExpired(token)) {
        debugPrint('TOKEN EXPIRED — hapus sesi');
        // Hapus semua data tersimpan
        await Future.wait([
          _storage.delete(key: AppStrings.tokenKey),
          _storage.delete(key: AppStrings.userIdKey),
          _storage.delete(key: AppStrings.userNameKey),
          _storage.delete(key: AppStrings.userEmailKey),
          _storage.delete(key: AppStrings.userRoleKey),
        ]);
        return null;
      }

      debugPrint('TOKEN VALID — sisa waktu: ${JwtUtils.remainingTime(token)}');

      return LoginResponseModel(
        success: true,
        message: 'Session restored',
        token: token,
        user: UserModel(id: id, name: name, email: email, role: role),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<EmailSenderResponseModel> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        AppStrings.forgotPasswordRequestEndpoint,
        data: {'email': email},
      );

      return EmailSenderResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Gagal mengirim email');
    }
  }

  @override
  Future<VerifyCodeResponseModel> verifyCode(String email, String otp) async {
    try {
      final response = await _dio.post(
        AppStrings.verifyCodeEndpoint,
        data: {'email': email, 'otp': otp},
      );

      return VerifyCodeResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Gagal verify');
    }
  }

  @override
  Future<ResetPasswordResponseModel> resetPassword(
    String confirmPassword,
    String newPassword,
    String token,
  ) async {
    try {
      final response = await _dio.post(
        AppStrings.forgotPasswordResetEndpoint,
        data: {
          'confirm_password': confirmPassword,
          'new_password': newPassword,
          'token': token,
        },
      );

      return ResetPasswordResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Gagal reset password');
    }
  }
}

// Provider inject Dio dari dioProvider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepositoryImpl(dio);
});

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/app_strings.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
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
      final id = await _storage.read(key: 'user_id');
      final name = await _storage.read(key: 'user_name');
      final email = await _storage.read(key: 'user_email');
      final role = await _storage.read(key: 'user_role');

      // Jika salah satu tidak ada, anggap belum login
      if (token == null ||
          id == null ||
          name == null ||
          email == null ||
          role == null) {
        return null;
      }

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
        AppStrings.verifyCodeEndpoint,
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

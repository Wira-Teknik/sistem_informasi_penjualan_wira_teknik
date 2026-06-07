import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/app_strings.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/jwt_utils.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/user_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/auth_repository.dart';

class LoginState {
  final bool isLoading;
  final bool isPasswordVisible;
  final String? errorMessage;
  final UserModel? user;
  final String? token;
  final bool isTokenExpired;

  const LoginState({
    this.isLoading = false,
    this.isPasswordVisible = false,
    this.errorMessage,
    this.user,
    this.token,
    this.isTokenExpired = false,
  });

  bool get isSuccess => user != null && token != null && !isTokenExpired;

  LoginState copyWith({
    bool? isLoading,
    bool? isPasswordVisible,
    String? errorMessage,
    UserModel? user,
    String? token,
    bool? isTokenExpired,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
      token: token ?? this.token,
      isTokenExpired: isTokenExpired ?? this.isTokenExpired,
    );
  }
}

class LoginViewModel extends StateNotifier<LoginState> {
  final AuthRepository _authRepository;
  final _storage = const FlutterSecureStorage();

  LoginViewModel(this._authRepository) : super(const LoginState()) {
    checkSession();
  }

  Future<void> checkSession() async {
    state = state.copyWith(isLoading: true);

    final session = await _authRepository.getSavedSession();

    if (session != null) {
      // Double check token di sisi viewmodel
      if (JwtUtils.isExpired(session.token)) {
        await logout();
        state = state.copyWith(isLoading: false, isTokenExpired: true);
        return;
      }

      state = state.copyWith(
        isLoading: false,
        user: session.user,
        token: session.token,
        isTokenExpired: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _authRepository.login(username, password);

      await Future.wait([
        _storage.write(key: AppStrings.tokenKey, value: result.token),
        _storage.write(key: AppStrings.userIdKey, value: result.user.id),
        _storage.write(key: AppStrings.userNameKey, value: result.user.name),
        _storage.write(key: AppStrings.userEmailKey, value: result.user.email),
        _storage.write(key: AppStrings.userRoleKey, value: result.user.role),
      ]);

      state = state.copyWith(
        isLoading: false,
        user: result.user,
        token: result.token,
        isTokenExpired: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    await Future.wait([
      _storage.delete(key: AppStrings.tokenKey),
      _storage.delete(key: AppStrings.userIdKey),
      _storage.delete(key: AppStrings.userNameKey),
      _storage.delete(key: AppStrings.userEmailKey),
      _storage.delete(key: AppStrings.userRoleKey),
    ]);
    state = const LoginState();
  }

  void resetState() => state = const LoginState();
}

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return LoginViewModel(repository);
    });

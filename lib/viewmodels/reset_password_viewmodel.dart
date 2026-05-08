import 'package:flutter_riverpod/legacy.dart';
import '../data/repositories/auth_repository.dart';

class ResetPasswordState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const ResetPasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ResetPasswordViewmodel extends StateNotifier<ResetPasswordState> {
  final AuthRepository _authRepository;

  ResetPasswordViewmodel(this._authRepository)
    : super(const ResetPasswordState());

  Future<void> resetPassword(
    String confirmPassword,
    String newPassword,
    String token,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authRepository.resetPassword(confirmPassword, newPassword, token);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void resetState() {
    state = const ResetPasswordState();
  }
}

final resetPasswordViewModelProvider =
    StateNotifierProvider<ResetPasswordViewmodel, ResetPasswordState>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return ResetPasswordViewmodel(repository);
    });

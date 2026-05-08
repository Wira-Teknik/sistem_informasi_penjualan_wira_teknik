import 'package:flutter_riverpod/legacy.dart';
import '../data/repositories/auth_repository.dart';

class VerifyCodeState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? token;

  const VerifyCodeState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.token,
  });

  VerifyCodeState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? token,
    bool clearError = false,
  }) {
    return VerifyCodeState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      token: token ?? this.token, // ← tambah di copyWith
    );
  }
}

class VerifyCodeViewmodel extends StateNotifier<VerifyCodeState> {
  final AuthRepository _authRepository;

  VerifyCodeViewmodel(this._authRepository) : super(const VerifyCodeState());

  Future<void> verifyCode(String email, String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Repository mengembalikan token dari response API
      final result = await _authRepository.verifyCode(email, otp);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        token: result.token,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void resetState() {
    state = const VerifyCodeState();
  }
}

final verifyCodeViewModelProvider =
    StateNotifierProvider<VerifyCodeViewmodel, VerifyCodeState>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return VerifyCodeViewmodel(repository);
    });

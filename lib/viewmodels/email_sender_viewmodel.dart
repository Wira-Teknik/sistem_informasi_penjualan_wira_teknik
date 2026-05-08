import 'package:flutter_riverpod/legacy.dart';
import '../data/repositories/auth_repository.dart';

// State untuk halaman forgot password
class EmailSenderState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const EmailSenderState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  EmailSenderState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EmailSenderState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ViewModel wajib extends StateNotifier dengan tipe State-nya
class EmailSenderViewmodel extends StateNotifier<EmailSenderState> {
  final AuthRepository _authRepository;

  // Wajib panggil super() dengan state awal
  EmailSenderViewmodel(this._authRepository) : super(const EmailSenderState());

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _authRepository.forgotPassword(email);

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
    state = const EmailSenderState();
  }
}

// StateNotifierProvider wajib dua tipe: <ViewModel, State>
final emailSenderViewModelProvider =
    StateNotifierProvider<EmailSenderViewmodel, EmailSenderState>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return EmailSenderViewmodel(repository);
    });

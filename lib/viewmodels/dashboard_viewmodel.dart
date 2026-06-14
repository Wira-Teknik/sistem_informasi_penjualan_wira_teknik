import 'dart:async'; // Wajib di-import untuk menggunakan Timer
import 'package:flutter_riverpod/legacy.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/dashboard_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/dashboard_repository.dart';

class DashboardState {
  final bool isLoading;
  final bool isRefreshing;
  final DashboardMetricsModel? data;
  final String? errorMessage;

  const DashboardState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.data,
    this.errorMessage,
  });

  DashboardState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    DashboardMetricsModel? data,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      data: data ?? this.data,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DashboardViewModel extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;
  Timer? _pollingTimer;

  DashboardViewModel(this._repository) : super(const DashboardState()) {
    loadDashboard();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _pollingTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      _silentRefresh();
    });
  }

  Future<void> _silentRefresh() async {
    try {
      final data = await _repository.getDashboard();
      state = state.copyWith(data: data, clearError: true);
    } on Exception catch (_) {}
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _repository.getDashboard();
      state = state.copyWith(isLoading: false, data: data);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      final data = await _repository.getDashboard();
      state = state.copyWith(isRefreshing: false, data: data);
    } on Exception catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
      final repository = ref.watch(dashboardRepositoryProvider);
      return DashboardViewModel(repository);
    });

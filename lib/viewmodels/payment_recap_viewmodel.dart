import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import '../data/models/payment_recap_model.dart';
import '../data/repositories/payment_recap_repository.dart';

class PaymentRecapState {
  final bool isLoading;
  final bool isRefreshing;
  final PaymentRecapModel? data;
  final String? errorMessage;
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;

  const PaymentRecapState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.data,
    this.errorMessage,
    this.startDate,
    this.endDate,
    this.searchQuery = '',
  });

  PaymentRecapState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    PaymentRecapModel? data,
    String? errorMessage,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    bool clearError = false,
  }) {
    return PaymentRecapState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      data: data ?? this.data,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PaymentRecapViewModel extends StateNotifier<PaymentRecapState> {
  final PaymentRecapRepository _repository;

  Timer? _debounceTimer;
  String _lastQuery = '';

  PaymentRecapViewModel(this._repository) : super(const PaymentRecapState()) {
    loadRecap();
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> loadRecap() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _repository.getRecap(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );
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
      final data = await _repository.getRecap(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );
      state = state.copyWith(isRefreshing: false, data: data);
    } on Exception catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Update date range dan reload
  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
    loadRecap();
  }

  // Search dengan debounce
  void search(String query) {
    _lastQuery = query;
    state = state.copyWith(searchQuery: query);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_lastQuery == query) loadRecap();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final paymentRecapViewModelProvider =
    StateNotifierProvider<PaymentRecapViewModel, PaymentRecapState>((ref) {
      final repository = ref.watch(paymentRecapRepositoryProvider);
      return PaymentRecapViewModel(repository);
    });

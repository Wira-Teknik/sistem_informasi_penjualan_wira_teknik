import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_recap_detail_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/payment_recap_repository.dart';

class PaymentRecapDetailUnpaidState {
  final bool isLoading;
  final bool isRefreshing;
  final PaymentRecapDetailUnpaidModel? data;
  final List<PaymentRecapDetailItemModel> filteredItems;
  final String? errorMessage;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const PaymentRecapDetailUnpaidState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.data,
    this.filteredItems = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.startDate,
    this.endDate,
  });

  PaymentRecapDetailUnpaidState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    PaymentRecapDetailUnpaidModel? data,
    List<PaymentRecapDetailItemModel>? filteredItems,
    String? errorMessage,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool clearError = false,
  }) {
    return PaymentRecapDetailUnpaidState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      data: data ?? this.data,
      filteredItems: filteredItems ?? this.filteredItems,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class PaymentRecapDetailUnpaidViewModel
    extends StateNotifier<PaymentRecapDetailUnpaidState> {
  final PaymentRecapRepository _repository;

  Timer? _debounceTimer;
  String _lastQuery = '';

  PaymentRecapDetailUnpaidViewModel(
    this._repository, {
    DateTime? startDate,
    DateTime? endDate,
  }) : super(
         PaymentRecapDetailUnpaidState(startDate: startDate, endDate: endDate),
       ) {
    loadDetail();
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> loadDetail() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _repository.getDetailUnpaid(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );
      state = state.copyWith(
        isLoading: false,
        data: data,
        filteredItems: data.items,
      );
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
      final data = await _repository.getDetailUnpaid(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );
      state = state.copyWith(
        isRefreshing: false,
        data: data,
        filteredItems: data.items,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void search(String query) {
    _lastQuery = query;
    state = state.copyWith(searchQuery: query);

    // Filter lokal dulu
    final items = state.data?.items ?? [];
    final keyword = query.toLowerCase().trim();
    final local = query.isEmpty
        ? items
        : items
              .where(
                (item) =>
                    item.poNo.toLowerCase().contains(keyword) ||
                    item.customerName.toLowerCase().contains(keyword),
              )
              .toList();

    state = state.copyWith(filteredItems: local);

    // Debounce hit API
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_lastQuery == query) loadDetail();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final paymentRecapDetailUnpaidViewModelProvider =
    StateNotifierProvider.family<
      PaymentRecapDetailUnpaidViewModel,
      PaymentRecapDetailUnpaidState,
      ({DateTime? startDate, DateTime? endDate})
    >((ref, params) {
      final repository = ref.watch(paymentRecapRepositoryProvider);
      return PaymentRecapDetailUnpaidViewModel(
        repository,
        startDate: params.startDate,
        endDate: params.endDate,
      );
    });

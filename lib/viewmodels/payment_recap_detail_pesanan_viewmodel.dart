import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_recap_detail_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/payment_recap_repository.dart';

class PaymentRecapDetailPesananState {
  final bool isLoading;
  final bool isRefreshing;
  final PaymentRecapDetailPesananModel? data;
  final List<PaymentRecapDetailPesananItemModel> filteredItems;
  final String? errorMessage;
  final int activeFilter;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const PaymentRecapDetailPesananState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.data,
    this.filteredItems = const [],
    this.errorMessage,
    this.activeFilter = 0,
    this.searchQuery = '',
    this.startDate,
    this.endDate,
  });

  // Map index filter ke order_status
  static const _filterStatus = {
    0: null,
    1: 'Pending',
    2: 'Partial',
    3: 'Shipped',
    4: 'Completed',
  };

  PaymentRecapDetailPesananState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    PaymentRecapDetailPesananModel? data,
    List<PaymentRecapDetailPesananItemModel>? filteredItems,
    String? errorMessage,
    int? activeFilter,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool clearError = false,
  }) {
    return PaymentRecapDetailPesananState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      data: data ?? this.data,
      filteredItems: filteredItems ?? this.filteredItems,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class PaymentRecapDetailPesananViewModel
    extends StateNotifier<PaymentRecapDetailPesananState> {
  final PaymentRecapRepository _repository;

  Timer? _debounceTimer;
  String _lastQuery = '';

  PaymentRecapDetailPesananViewModel(
    this._repository, {
    DateTime? startDate,
    DateTime? endDate,
  }) : super(
         PaymentRecapDetailPesananState(startDate: startDate, endDate: endDate),
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
      final data = await _repository.getDetailPesanan(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );
      state = state.copyWith(
        isLoading: false,
        data: data,
        filteredItems: _applyFilter(data.items, state.activeFilter),
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
      final data = await _repository.getDetailPesanan(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );
      state = state.copyWith(
        isRefreshing: false,
        data: data,
        filteredItems: _applyFilter(data.items, state.activeFilter),
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void setFilter(int index) {
    final items = state.data?.items ?? [];
    state = state.copyWith(
      activeFilter: index,
      filteredItems: _applyFilter(items, index),
    );
  }

  void search(String query) {
    _lastQuery = query;
    state = state.copyWith(searchQuery: query);

    // Filter lokal dulu
    final items = state.data?.items ?? [];
    final keyword = query.toLowerCase().trim();
    final local = items
        .where(
          (item) =>
              item.poNo.toLowerCase().contains(keyword) ||
              item.customerName.toLowerCase().contains(keyword),
        )
        .toList();

    state = state.copyWith(
      filteredItems: _applyFilter(local, state.activeFilter),
    );

    // Debounce hit API
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_lastQuery == query) loadDetail();
    });
  }

  List<PaymentRecapDetailPesananItemModel> _applyFilter(
    List<PaymentRecapDetailPesananItemModel> items,
    int filterIndex,
  ) {
    final status = PaymentRecapDetailPesananState._filterStatus[filterIndex];
    if (status == null) return items;
    return items
        .where((i) => i.orderStatus.toLowerCase() == status.toLowerCase())
        .toList();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final paymentRecapDetailPesananViewModelProvider =
    StateNotifierProvider.family<
      PaymentRecapDetailPesananViewModel,
      PaymentRecapDetailPesananState,
      ({DateTime? startDate, DateTime? endDate})
    >((ref, params) {
      final repository = ref.watch(paymentRecapRepositoryProvider);
      return PaymentRecapDetailPesananViewModel(
        repository,
        startDate: params.startDate,
        endDate: params.endDate,
      );
    });

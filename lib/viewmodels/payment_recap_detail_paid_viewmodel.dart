import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_recap_detail_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/payment_recap_repository.dart';

class PaymentRecapDetailPaidState {
  final bool isLoading;
  final bool isLoadMore;
  final bool isRefreshing;
  final bool isDownloading;

  final PaymentRecapDetailPaidModel? data;

  final List<PaymentRecapDetailItemModel> items;
  final List<PaymentRecapDetailItemModel> filteredItems;

  final String? errorMessage;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  final int currentPage;
  final bool hasReachedMax;

  const PaymentRecapDetailPaidState({
    this.isLoading = false,
    this.isLoadMore = false,
    this.isRefreshing = false,
    this.isDownloading = false,
    this.data,
    this.items = const [],
    this.filteredItems = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.startDate,
    this.endDate,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  PaymentRecapDetailPaidState copyWith({
    bool? isLoading,
    bool? isLoadMore,
    bool? isRefreshing,
    bool? isDownloading,
    PaymentRecapDetailPaidModel? data,
    List<PaymentRecapDetailItemModel>? items,
    List<PaymentRecapDetailItemModel>? filteredItems,
    String? errorMessage,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    int? currentPage,
    bool? hasReachedMax,
    bool clearError = false,
  }) {
    return PaymentRecapDetailPaidState(
      isLoading: isLoading ?? this.isLoading,
      isLoadMore: isLoadMore ?? this.isLoadMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isDownloading: isDownloading ?? this.isDownloading,
      data: data ?? this.data,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class PaymentRecapDetailPaidViewModel
    extends StateNotifier<PaymentRecapDetailPaidState> {
  final PaymentRecapRepository _repository;

  Timer? _debounceTimer;
  String _lastQuery = '';

  PaymentRecapDetailPaidViewModel(
    this._repository, {
    DateTime? startDate,
    DateTime? endDate,
  }) : super(
         PaymentRecapDetailPaidState(startDate: startDate, endDate: endDate),
       ) {
    loadDetail();
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  List<PaymentRecapDetailItemModel> _applyLocalFilter(
    List<PaymentRecapDetailItemModel> itemsList,
    String query,
  ) {
    if (query.isEmpty) return itemsList;
    final keyword = query.toLowerCase().trim();
    return itemsList
        .where(
          (item) =>
              item.poNo.toLowerCase().contains(keyword) ||
              item.customerName.toLowerCase().contains(keyword),
        )
        .toList();
  }

  Future<void> loadDetail({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (state.hasReachedMax ||
          state.isLoading ||
          state.isLoadMore ||
          state.isRefreshing) {
        return;
      }
      state = state.copyWith(isLoadMore: true, clearError: true);
    } else {
      state = state.copyWith(
        isLoading: true,
        currentPage: 1,
        hasReachedMax: false,
        clearError: true,
      );
    }

    try {
      final response = await _repository.getDetailPaid(
        page: state.currentPage,
        limit: 20,
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      final newItems = response.data?.items ?? [];
      final totalPages = response.pagination?.totalPages ?? 1;

      final currentList = isLoadMore
          ? List<PaymentRecapDetailItemModel>.from(state.items)
          : <PaymentRecapDetailItemModel>[];
      currentList.addAll(newItems);

      state = state.copyWith(
        isLoading: false,
        isLoadMore: false,
        data: response.data,
        items: currentList,
        filteredItems: _applyLocalFilter(currentList, state.searchQuery),
        currentPage: isLoadMore ? state.currentPage + 1 : 2,
        hasReachedMax: isLoadMore
            ? (state.currentPage >= totalPages)
            : (1 >= totalPages),
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadMore: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
      currentPage: 1,
      hasReachedMax: false,
    );
    try {
      final response = await _repository.getDetailPaid(
        page: 1,
        limit: 20,
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      final newItems = response.data?.items ?? [];
      final totalPages = response.pagination?.totalPages ?? 1;

      state = state.copyWith(
        isRefreshing: false,
        data: response.data,
        items: newItems,
        filteredItems: _applyLocalFilter(newItems, state.searchQuery),
        currentPage: 2,
        hasReachedMax: 1 >= totalPages,
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

    state = state.copyWith(
      searchQuery: query,
      filteredItems: _applyLocalFilter(state.items, query),
    );

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_lastQuery == query) loadDetail();
    });
  }

  Future<String?> exportToExcel() async {
    state = state.copyWith(isDownloading: true, clearError: true);
    try {
      final filePath = await _repository.exportDetail(
        endpoint: '/payment-recap/detail-paid/export',
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        fileName: 'detail_paid_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      );
      state = state.copyWith(isDownloading: false);
      return filePath;
    } on Exception catch (e) {
      state = state.copyWith(
        isDownloading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final paymentRecapDetailPaidViewModelProvider =
    StateNotifierProvider.family<
      PaymentRecapDetailPaidViewModel,
      PaymentRecapDetailPaidState,
      ({DateTime? startDate, DateTime? endDate})
    >((ref, params) {
      final repository = ref.watch(paymentRecapRepositoryProvider);
      return PaymentRecapDetailPaidViewModel(
        repository,
        startDate: params.startDate,
        endDate: params.endDate,
      );
    });

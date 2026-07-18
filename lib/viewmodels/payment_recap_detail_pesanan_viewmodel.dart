import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/app_strings.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_recap_detail_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/payment_recap_repository.dart';

class PaymentRecapDetailPesananState {
  final bool isLoading;
  final bool isLoadMore;
  final bool isRefreshing;
  final bool isDownloading;

  final PaymentRecapDetailPesananModel? data;

  final List<PaymentRecapDetailPesananItemModel> items;
  final List<PaymentRecapDetailPesananItemModel> filteredItems;

  final String? errorMessage;
  final int activeFilter;
  final String searchQuery;

  final int currentPage;
  final bool hasReachedMax;

  final DateTime? startDate;
  final DateTime? endDate;

  const PaymentRecapDetailPesananState({
    this.isLoading = false,
    this.isLoadMore = false,
    this.isRefreshing = false,
    this.isDownloading = false,
    this.data,
    this.items = const [],
    this.filteredItems = const [],
    this.errorMessage,
    this.activeFilter = 0,
    this.searchQuery = '',
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.startDate,
    this.endDate,
  });

  static const _filterStatus = {
    0: null,
    1: 'Pending',
    2: 'Partial',
    3: 'Shipped',
    4: 'Completed',
  };

  PaymentRecapDetailPesananState copyWith({
    bool? isLoading,
    bool? isLoadMore,
    bool? isRefreshing,
    bool? isDownloading,
    PaymentRecapDetailPesananModel? data,
    List<PaymentRecapDetailPesananItemModel>? items,
    List<PaymentRecapDetailPesananItemModel>? filteredItems,
    String? errorMessage,
    int? activeFilter,
    String? searchQuery,
    int? currentPage,
    bool? hasReachedMax,
    DateTime? startDate,
    DateTime? endDate,
    bool clearError = false,
  }) {
    return PaymentRecapDetailPesananState(
      isLoading: isLoading ?? this.isLoading,
      isLoadMore: isLoadMore ?? this.isLoadMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isDownloading: isDownloading ?? this.isDownloading,
      data: data ?? this.data,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
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
      final response = await _repository.getDetailPesanan(
        page: state.currentPage,
        limit: 20,
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      final newItems = response.data?.items ?? [];
      final totalPages = response.pagination?.totalPages ?? 1;

      final currentList = isLoadMore
          ? List<PaymentRecapDetailPesananItemModel>.from(state.items)
          : <PaymentRecapDetailPesananItemModel>[];
      currentList.addAll(newItems);

      state = state.copyWith(
        isLoading: false,
        isLoadMore: false,
        data: response.data,
        items: currentList,
        filteredItems: _applyFilter(currentList, state.activeFilter),
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
      final response = await _repository.getDetailPesanan(
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
        filteredItems: _applyFilter(newItems, state.activeFilter),
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

  void setFilter(int index) {
    state = state.copyWith(
      activeFilter: index,
      filteredItems: _applyFilter(state.items, index),
    );
  }

  void search(String query) {
    _lastQuery = query;
    final keyword = query.toLowerCase().trim();

    final local = state.items
        .where(
          (item) =>
              item.poNo.toLowerCase().contains(keyword) ||
              item.customerName.toLowerCase().contains(keyword),
        )
        .toList();

    state = state.copyWith(
      searchQuery: query,
      filteredItems: _applyFilter(local, state.activeFilter),
    );

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

  Future<String?> exportToExcel() async {
    state = state.copyWith(isDownloading: true, clearError: true);
    try {
      final filePath = await _repository.exportDetail(
        endpoint: '${AppStrings.paymentRecapEndpoint}/detail-pesanan/export',
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        status:
            PaymentRecapDetailPesananState._filterStatus[state.activeFilter],
        fileName:
            'detail_pesanan_${DateTime.now().millisecondsSinceEpoch}.xlsx',
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

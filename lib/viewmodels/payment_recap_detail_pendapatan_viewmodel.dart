import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_recap_detail_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/payment_recap_repository.dart';

class PaymentRecapDetailPendapatanState {
  final bool isLoading;
  final bool isLoadMore;
  final bool isRefreshing;
  final bool isDownloading;

  final PaymentRecapDetailPendapatanModel? data;

  final List<PaymentRecapDetailItemModel> items;
  final List<PaymentRecapDetailItemModel> filteredItems;

  final String? errorMessage;
  final int activeFilter;
  final String searchQuery;

  final int currentPage;
  final bool hasReachedMax;

  final DateTime? startDate;
  final DateTime? endDate;

  const PaymentRecapDetailPendapatanState({
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
    0: null, // semua
    1: 'Unpaid',
    2: 'Partial',
    3: 'Paid',
  };

  PaymentRecapDetailPendapatanState copyWith({
    bool? isLoading,
    bool? isLoadMore,
    bool? isRefreshing,
    bool? isDownloading,
    PaymentRecapDetailPendapatanModel? data,
    List<PaymentRecapDetailItemModel>? items,
    List<PaymentRecapDetailItemModel>? filteredItems,
    String? errorMessage,
    int? activeFilter,
    String? searchQuery,
    int? currentPage,
    bool? hasReachedMax,
    DateTime? startDate,
    DateTime? endDate,
    bool clearError = false,
  }) {
    return PaymentRecapDetailPendapatanState(
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

class PaymentRecapDetailPendapatanViewModel
    extends StateNotifier<PaymentRecapDetailPendapatanState> {
  final PaymentRecapRepository _repository;

  Timer? _debounceTimer;
  String _lastQuery = '';

  PaymentRecapDetailPendapatanViewModel(
    this._repository, {
    DateTime? startDate,
    DateTime? endDate,
  }) : super(
         PaymentRecapDetailPendapatanState(
           startDate: startDate,
           endDate: endDate,
         ),
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
      final response = await _repository.getDetailPendapatan(
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
      final response = await _repository.getDetailPendapatan(
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

  List<PaymentRecapDetailItemModel> _applyFilter(
    List<PaymentRecapDetailItemModel> items,
    int filterIndex,
  ) {
    final status = PaymentRecapDetailPendapatanState._filterStatus[filterIndex];
    if (status == null) return items;
    return items
        .where((i) => i.paymentStatus.toLowerCase() == status.toLowerCase())
        .toList();
  }

  Future<String?> exportToExcel() async {
    state = state.copyWith(isDownloading: true, clearError: true);
    try {
      final filePath = await _repository.exportDetail(
        endpoint: '/payment-recap/detail-pendapatan/export',
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        status:
            PaymentRecapDetailPendapatanState._filterStatus[state.activeFilter],
        fileName:
            'detail_pendapatan_${DateTime.now().millisecondsSinceEpoch}.xlsx',
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

final paymentRecapDetailPendapatanViewModelProvider =
    StateNotifierProvider.family<
      PaymentRecapDetailPendapatanViewModel,
      PaymentRecapDetailPendapatanState,
      ({DateTime? startDate, DateTime? endDate})
    >((ref, params) {
      final repository = ref.watch(paymentRecapRepositoryProvider);
      return PaymentRecapDetailPendapatanViewModel(
        repository,
        startDate: params.startDate,
        endDate: params.endDate,
      );
    });

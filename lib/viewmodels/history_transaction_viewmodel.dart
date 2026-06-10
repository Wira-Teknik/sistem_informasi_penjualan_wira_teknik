import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/history_transaction_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/history_transaction_repository.dart';

class HistoryTransactionState {
  final bool isLoading;
  final bool isLoadMore;
  final bool isRefreshing;
  final bool isDownloading;
  final List<HistoryTransactionModel> transactions;
  final List<HistoryTransactionModel> filteredTransactions;
  final int activeFilter;
  final String? errorMessage;

  final int currentPage;
  final bool hasReachedMax;

  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;
  final String status;

  const HistoryTransactionState({
    this.isLoading = false,
    this.isLoadMore = false,
    this.isRefreshing = false,
    this.isDownloading = false,
    this.transactions = const [],
    this.filteredTransactions = const [],
    this.activeFilter = 0,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.errorMessage,
    this.startDate,
    this.endDate,
    this.searchQuery = '',
    this.status = '',
  });

  bool get hasActiveFilter =>
      startDate != null ||
      endDate != null ||
      searchQuery.isNotEmpty ||
      status.isNotEmpty;

  HistoryTransactionState copyWith({
    bool? isLoading,
    bool? isLoadMore,
    bool? isRefreshing,
    bool? isDownloading,
    List<HistoryTransactionModel>? transactions,
    List<HistoryTransactionModel>? filteredTransactions,
    String? errorMessage,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? status,
    int? activeFilter,
    int? currentPage,
    bool? hasReachedMax,
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return HistoryTransactionState(
      isLoading: isLoading ?? this.isLoading,
      isLoadMore: isLoadMore ?? this.isLoadMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isDownloading: isDownloading ?? this.isDownloading,
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      startDate: clearFilter ? null : (startDate ?? this.startDate),
      endDate: clearFilter ? null : (endDate ?? this.endDate),
      searchQuery: clearFilter ? '' : (searchQuery ?? this.searchQuery),
      status: clearFilter ? '' : (status ?? this.status),
      activeFilter: clearFilter ? 0 : (activeFilter ?? this.activeFilter),
    );
  }
}

class HistoryTransactionViewModel
    extends StateNotifier<HistoryTransactionState> {
  final HistoryTransactionRepository _repository;

  Timer? _debounceTimer;
  // ignore: unused_field
  String _lastQuery = '';

  HistoryTransactionViewModel(this._repository)
    : super(const HistoryTransactionState()) {
    loadHistory();
  }

  static const _filterStatus = {0: null, 1: 'unpaid', 2: 'partial', 3: 'paid'};

  List<HistoryTransactionModel> _applyFilter(
    List<HistoryTransactionModel> transactions,
    int filterIndex,
  ) {
    final status = _filterStatus[filterIndex];
    if (status == null) {
      return List.from(transactions);
    }

    return transactions.where((t) {
      return t.paymentStatus.toLowerCase() == status.toLowerCase();
    }).toList();
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> loadHistory({bool isLoadMore = false}) async {
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
      final response = await _repository.getHistory(
        page: state.currentPage,
        limit: 20,
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        status: state.status.isNotEmpty ? state.status : null,
      );

      final newTransactions = response.data;
      final totalPages = response.pagination.totalPages;

      final currentList = isLoadMore
          ? List<HistoryTransactionModel>.from(state.transactions)
          : <HistoryTransactionModel>[];
      currentList.addAll(newTransactions);

      state = state.copyWith(
        isLoading: false,
        isLoadMore: false,
        transactions: currentList,
        filteredTransactions: _applyFilter(currentList, state.activeFilter),
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
      final response = await _repository.getHistory(
        page: 1,
        limit: 20,
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        status: state.status.isNotEmpty ? state.status : null,
      );

      final newTransactions = response.data;
      final totalPages = response.pagination.totalPages;

      state = state.copyWith(
        isRefreshing: false,
        transactions: newTransactions,
        filteredTransactions: _applyFilter(newTransactions, state.activeFilter),
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

  Future<void> applyAdvanceFilter({
    DateTime? startDate,
    DateTime? endDate,
    String? search,
    String? status,
  }) async {
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      searchQuery: search ?? '',
      status: status ?? '',
      activeFilter: 0,
    );
    await loadHistory();
  }

  Future<void> resetFilter() async {
    state = state.copyWith(clearFilter: true, activeFilter: 0);
    await loadHistory();
  }

  void setFilter(int index) {
    state = state.copyWith(
      activeFilter: index,
      filteredTransactions: _applyFilter(state.transactions, index),
    );
  }

  void search(String query) {
    _lastQuery = query;

    if (query.isEmpty) {
      _debounceTimer?.cancel();
      state = state.copyWith(
        searchQuery: '',
        activeFilter: 0,
        filteredTransactions: List.from(state.transactions),
      );
      loadHistory();
      return;
    }

    final keyword = query.toLowerCase().trim();
    final filtered = state.transactions.where((t) {
      return t.poNo.toLowerCase().contains(keyword) ||
          t.transactionNo.toLowerCase().contains(keyword) ||
          t.customerName.toLowerCase().contains(keyword);
    }).toList();

    state = state.copyWith(filteredTransactions: filtered, activeFilter: 0);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      state = state.copyWith(searchQuery: query);
      loadHistory();
    });
  }

  Future<String?> exportToExcel() async {
    state = state.copyWith(isDownloading: true, clearError: true);
    try {
      final filePath = await _repository.exportHistoryTransaction(
        endpoint: '/payments/history/export',
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        status: state.status.isNotEmpty ? state.status : null,
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        fileName:
            'history_transaction_${DateTime.now().millisecondsSinceEpoch}.xlsx',
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

final historyTransactionViewModelProvider =
    StateNotifierProvider<HistoryTransactionViewModel, HistoryTransactionState>(
      (ref) {
        final repository = ref.watch(historyTransactionRepositoryProvider);
        return HistoryTransactionViewModel(repository);
      },
    );

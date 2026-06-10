import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/history_transaction_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/history_transaction_repository.dart';

class HistoryTransactionState {
  final bool isLoading;
  final bool isRefreshing;
  final bool isDownloading;
  final List<HistoryTransactionModel> transactions;
  final List<HistoryTransactionModel> filteredTransactions;
  final int activeFilter;
  final String? errorMessage;

  // Parameter API Filter
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery; // Menggantikan name/poNo terpisah
  final String status; // String status langsung

  const HistoryTransactionState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isDownloading = false,
    this.transactions = const [],
    this.filteredTransactions = const [],
    this.activeFilter = 0,
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
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return HistoryTransactionState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isDownloading: isDownloading ?? this.isDownloading,
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),

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
  String _lastQuery = '';

  HistoryTransactionViewModel(this._repository)
    : super(const HistoryTransactionState()) {
    loadHistory();
  }

  // Pastikan indeks dan nilainya selaras dengan urutan di UI
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

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final transactions = await _repository.getHistory(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        status: state.status.isNotEmpty ? state.status : null,
      );
      state = state.copyWith(
        isLoading: false,
        transactions: transactions,
        filteredTransactions: List.from(transactions),
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
      final transactions = await _repository.getHistory(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        status: state.status.isNotEmpty ? state.status : null,
      );
      state = state.copyWith(
        isRefreshing: false,
        transactions: transactions,
        filteredTransactions: List.from(transactions),
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Dipanggil oleh UI Bottom Sheet
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

  // Dipanggil oleh UI Bottom Sheet (Tombol Reset)
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
      _searchFromApi();
    });
  }

  Future<void> _searchFromApi() async {
    try {
      final transactions = await _repository.getHistory(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        search: state.searchQuery,
        status: state.status.isNotEmpty ? state.status : null,
      );
      if (_lastQuery != state.searchQuery) return;

      state = state.copyWith(filteredTransactions: List.from(transactions));
    } on Exception catch (_) {
      // Abaikan
    }
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

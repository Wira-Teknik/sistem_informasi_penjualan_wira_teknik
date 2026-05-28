import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/history_transaction_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/history_transaction_repository.dart';

class HistoryTransactionState {
  final bool isLoading;
  final bool isRefreshing;
  final bool isDownloading;
  final List<HistoryTransactionModel> transactions;
  final List<HistoryTransactionModel> filteredTransactions;
  final String? errorMessage;
  final int activeFilter;

  const HistoryTransactionState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isDownloading = false,
    this.transactions = const [],
    this.filteredTransactions = const [],
    this.errorMessage,
    this.activeFilter = 0,
  });

  HistoryTransactionState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isDownloading,
    List<HistoryTransactionModel>? transactions,
    List<HistoryTransactionModel>? filteredTransactions,
    String? errorMessage,
    int? activeFilter,
    bool clearError = false,
  }) {
    return HistoryTransactionState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isDownloading: isDownloading ?? this.isDownloading,
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

class HistoryTransactionViewModel
    extends StateNotifier<HistoryTransactionState> {
  final HistoryTransactionRepository _repository;

  Timer? _debounceTimer;
  String _lastQuery = '';

  // Map index filter ke payment_status
  static const _filterStatus = {
    0: null, // semua
    1: 'Unpaid',
    2: 'Partial',
    3: 'Paid',
  };

  HistoryTransactionViewModel(this._repository)
    : super(const HistoryTransactionState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final transactions = await _repository.getHistory();
      state = state.copyWith(
        isLoading: false,
        transactions: transactions,
        filteredTransactions: _applyFilter(transactions, state.activeFilter),
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
      final transactions = await _repository.getHistory();
      state = state.copyWith(
        isRefreshing: false,
        transactions: transactions,
        filteredTransactions: _applyFilter(transactions, state.activeFilter),
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
      filteredTransactions: _applyFilter(state.transactions, index),
    );
  }

  void search(String query) {
    _lastQuery = query;

    if (query.isEmpty) {
      _debounceTimer?.cancel();
      state = state.copyWith(
        filteredTransactions: _applyFilter(
          state.transactions,
          state.activeFilter,
        ),
      );
      return;
    }

    // Filter lokal dulu — instan
    state = state.copyWith(
      filteredTransactions: _filterAndSearch(
        state.transactions,
        query,
        state.activeFilter,
      ),
    );

    // Debounce hit API
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchFromApi(query);
    });
  }

  Future<void> _searchFromApi(String query) async {
    try {
      final transactions = await _repository.getHistory(query: query);
      if (_lastQuery != query) return;

      state = state.copyWith(
        filteredTransactions: _applyFilter(transactions, state.activeFilter),
      );
    } on Exception catch (_) {
      // Tetap tampil hasil filter lokal
    }
  }

  List<HistoryTransactionModel> _applyFilter(
    List<HistoryTransactionModel> transactions,
    int filterIndex,
  ) {
    final status = _filterStatus[filterIndex];
    if (status == null) return transactions;
    return transactions
        .where((t) => t.paymentStatus.toLowerCase() == status.toLowerCase())
        .toList();
  }

  List<HistoryTransactionModel> _filterAndSearch(
    List<HistoryTransactionModel> transactions,
    String query,
    int filterIndex,
  ) {
    final keyword = query.toLowerCase().trim();
    final filtered = _applyFilter(transactions, filterIndex);

    return filtered
        .where(
          (t) =>
              t.poNo.toLowerCase().contains(keyword) ||
              t.transactionNo.toLowerCase().contains(keyword) ||
              t.customerName.toLowerCase().contains(keyword),
        )
        .toList();
  }

  Future<String?> exportToExcel() async {
    state = state.copyWith(isDownloading: true, clearError: true);
    try {
      final filePath = await _repository.exportHistoryTransaction(
        endpoint: '/payments/history/export',
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

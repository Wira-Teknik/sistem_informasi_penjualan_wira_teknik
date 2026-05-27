import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_payment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/payment_repository.dart';

class PaymentState {
  final bool isLoading;
  final bool isRefreshing;
  final bool isSubmitting; // ← tambah
  final List<PaymentModel> payments;
  final List<PaymentModel> filteredPayments;
  final List<CustomerBillingModel> billings;
  final List<CustomerBillingModel> filteredBillings;
  final String? errorMessage;

  const PaymentState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isSubmitting = false, // ← tambah
    this.payments = const [],
    this.filteredPayments = const [],
    this.billings = const [],
    this.filteredBillings = const [],
    this.errorMessage,
  });

  PaymentState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isSubmitting,
    List<PaymentModel>? payments,
    List<PaymentModel>? filteredPayments,
    List<CustomerBillingModel>? billings,
    List<CustomerBillingModel>? filteredBillings,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      payments: payments ?? this.payments,
      filteredPayments: filteredPayments ?? this.filteredPayments,
      billings: billings ?? this.billings,
      filteredBillings: filteredBillings ?? this.filteredBillings,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class PaymentViewModel extends StateNotifier<PaymentState> {
  final PaymentRepository _repository;

  Timer? _debounceTimer; // ← debounce agar tidak hit API tiap keystroke
  String _lastQuery = ''; // ← cegah hasil lama menimpa hasil baru

  PaymentViewModel(this._repository) : super(const PaymentState()) {
    loadBillings();
  }

  Future<void> loadBillings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final billings = await _repository.getPayments();
      state = state.copyWith(
        isLoading: false,
        billings: billings,
        filteredBillings: billings,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan: $e',
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      final billings = await _repository.getPayments();
      state = state.copyWith(
        isRefreshing: false,
        billings: billings,
        filteredBillings: billings,
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

    if (query.isEmpty) {
      _debounceTimer?.cancel();
      state = state.copyWith(filteredBillings: state.billings);
      return;
    }

    // Filter + urutkan berdasarkan relevansi
    state = state.copyWith(
      filteredBillings: _filterAndSort(state.billings, query),
    );

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchFromApi(query);
    });
  }

  Future<void> _searchFromApi(String query) async {
    try {
      final billings = await _repository.getPayments(query: query);
      if (_lastQuery != query) return;

      // Urutkan hasil API juga berdasarkan relevansi
      state = state.copyWith(filteredBillings: _filterAndSort(billings, query));
    } on Exception catch (_) {
      // Tetap tampil hasil filter lokal
    }
  }

  // Urutkan: exact match → starts with → contains
  List<CustomerBillingModel> _filterAndSort(
    List<CustomerBillingModel> billings,
    String query,
  ) {
    final keyword = query.toLowerCase().trim();

    final exact = <CustomerBillingModel>[];
    final startsWith = <CustomerBillingModel>[];
    final contains = <CustomerBillingModel>[];

    for (final billing in billings) {
      final name = billing.customerName.toLowerCase();

      if (name == keyword) {
        exact.add(billing); // ← nama persis sama
      } else if (name.startsWith(keyword)) {
        startsWith.add(billing); // ← nama diawali keyword
      } else if (name.contains(keyword)) {
        contains.add(billing); // ← nama mengandung keyword
      }
    }

    // Gabung: exact → startsWith → contains
    return [...exact, ...startsWith, ...contains];
  }

  Future<bool> addPayment(AddPaymentRequest request) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.addPayment(request);
      state = state.copyWith(isSubmitting: false);
      await loadBillings();
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updatePayment(String id, double paymentTotal) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.updatePayment(id, paymentTotal);
      state = state.copyWith(isSubmitting: false);
      await loadBillings(); // refresh list setelah update
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel(); // ← bersihkan timer
    super.dispose();
  }
}

final paymentViewModelProvider =
    StateNotifierProvider<PaymentViewModel, PaymentState>((ref) {
      final repository = ref.watch(paymentRepositoryProvider);
      return PaymentViewModel(repository);
    });

import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_payment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/payment_repository.dart';

class PaymentState {
  final bool isLoading;
  final bool isRefreshing;
  final bool isSubmitting;
  final List<PaymentModel> payments;
  final List<PaymentModel> filteredPayments;
  final List<CustomerBillingModel> billings;
  final List<CustomerBillingModel> filteredBillings;
  final String? errorMessage;

  // --- Parameter Advance Filter ---
  final DateTime? startDate;
  final DateTime? endDate;
  final String name; // Input nama dari filter
  final String status; // Input status dari filter

  const PaymentState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isSubmitting = false,
    this.payments = const [],
    this.filteredPayments = const [],
    this.billings = const [],
    this.filteredBillings = const [],
    this.errorMessage,
    this.startDate,
    this.endDate,
    this.name = '',
    this.status = '',
  });

  // Getter untuk indikator badge merah di Appbar
  bool get hasActiveFilter =>
      startDate != null ||
      endDate != null ||
      name.isNotEmpty ||
      status.isNotEmpty;

  PaymentState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isSubmitting,
    List<PaymentModel>? payments,
    List<PaymentModel>? filteredPayments,
    List<CustomerBillingModel>? billings,
    List<CustomerBillingModel>? filteredBillings,
    String? errorMessage,
    DateTime? startDate,
    DateTime? endDate,
    String? name,
    String? status,
    bool clearError = false,
    bool clearFilter = false, // True jika tekan tombol Reset
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
      // Jika clearFilter true, reset semua parameter filter
      startDate: clearFilter ? null : (startDate ?? this.startDate),
      endDate: clearFilter ? null : (endDate ?? this.endDate),
      name: clearFilter ? '' : (name ?? this.name),
      status: clearFilter ? '' : (status ?? this.status),
    );
  }
}

class PaymentViewModel extends StateNotifier<PaymentState> {
  final PaymentRepository _repository;

  Timer? _debounceTimer;
  String _lastQuery = '';
  DateTime? _lastFetchTime;

  static const _cacheDuration = Duration(minutes: 5);

  bool get _isCacheExpired =>
      _lastFetchTime == null ||
      DateTime.now().difference(_lastFetchTime!) > _cacheDuration;

  PaymentViewModel(this._repository) : super(const PaymentState()) {
    loadBillings();
  }

  // Helper konversi tanggal
  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Mengambil data dari API berdasarkan filter aktif di State
  Future<void> loadBillings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Pastikan Repository kamu (searchCustomerBilling) sudah mendukung parameter ini
      final billings = await _repository.searchCustomerBilling(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        query: state.name.isNotEmpty
            ? state.name
            : null, // Memakai name dari filter
        status: state.status.isNotEmpty ? state.status : null,
      );

      _lastFetchTime = DateTime.now();
      state = state.copyWith(
        isLoading: false,
        billings: billings,
        filteredBillings: List.from(billings),
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

  // Dipanggil saat klik "Terapkan Filter" di Bottom Sheet
  Future<void> applyAdvanceFilter({
    DateTime? startDate,
    DateTime? endDate,
    String? name,
    String? status,
  }) async {
    _lastFetchTime = null; // paksa API hit
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      name: name ?? '',
      status: status ?? '',
    );
    await loadBillings();
  }

  // Dipanggil saat klik "Reset" di Bottom Sheet
  Future<void> resetFilter() async {
    _lastFetchTime = null; // paksa API hit
    state = state.copyWith(clearFilter: true);
    await loadBillings();
  }

  Future<void> loadIfNeeded() async {
    // Jika cache kadaluwarsa atau ada filter yang nyala, panggil ulang
    if (!_isCacheExpired && !state.hasActiveFilter) return;
    await loadBillings();
  }

  Future<void> refresh() async {
    _lastFetchTime = null;
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      final billings = await _repository.searchCustomerBilling(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        query: state.name.isNotEmpty ? state.name : null,
        status: state.status.isNotEmpty ? state.status : null,
      );
      _lastFetchTime = DateTime.now();

      state = state.copyWith(
        isRefreshing: false,
        billings: billings,
        filteredBillings: List.from(billings),
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // --- Fungsi pencarian realtime (Debounce TextField Halaman Utama) ---
  void search(String query) {
    _lastQuery = query;

    if (query.isEmpty) {
      _debounceTimer?.cancel();
      // Reset filter nama ke kosong dan tampilkan ulang data (opsional: tanpa hit API jika cache ada)
      state = state.copyWith(
        name: '',
        filteredBillings: List.from(state.billings),
      );
      return;
    }

    // Filter lokal sementara menunggu respon API
    state = state.copyWith(
      filteredBillings: _filterAndSort(state.billings, query),
    );

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // Set value 'name' pada state dan hit API
      state = state.copyWith(name: query);
      _searchFromApi();
    });
  }

  Future<void> _searchFromApi() async {
    try {
      final billings = await _repository.searchCustomerBilling(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        query: state.name,
        status: state.status.isNotEmpty ? state.status : null,
      );
      if (_lastQuery != state.name) return;

      state = state.copyWith(
        filteredBillings: _filterAndSort(billings, state.name),
      );
    } on Exception catch (_) {
      // Gagal ambil API, abaikan.
    }
  }

  List<CustomerBillingModel> _filterAndSort(
    List<CustomerBillingModel> billings,
    String query,
  ) {
    if (query.trim().isEmpty) return List.from(billings);

    final keyword = query.toLowerCase().trim();
    final exact = <CustomerBillingModel>[];
    final startsWith = <CustomerBillingModel>[];
    final contains = <CustomerBillingModel>[];

    for (final billing in billings) {
      final name = billing.customerName.toLowerCase();

      if (name == keyword) {
        exact.add(billing);
      } else if (name.startsWith(keyword)) {
        startsWith.add(billing);
      } else if (name.contains(keyword)) {
        contains.add(billing);
      }
    }

    return [...exact, ...startsWith, ...contains];
  }

  Future<bool> addPayment(AddPaymentRequest request) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.addPayment(request);
      _lastFetchTime = null;
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
      _lastFetchTime = null;
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final paymentViewModelProvider =
    StateNotifierProvider<PaymentViewModel, PaymentState>((ref) {
      final repository = ref.watch(paymentRepositoryProvider);
      return PaymentViewModel(repository);
    });

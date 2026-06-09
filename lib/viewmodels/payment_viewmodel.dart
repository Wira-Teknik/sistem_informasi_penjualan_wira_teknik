import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_payment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_detail_model.dart';
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
  final CustomerBillingDetailModel? selectedCustomerDetail;
  final bool isDetailLoading;
  final String? errorMessage;

  final DateTime? startDate;
  final DateTime? endDate;
  final String name;
  final String status;

  const PaymentState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isSubmitting = false,
    this.selectedCustomerDetail,
    this.isDetailLoading = false,
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
    CustomerBillingDetailModel? selectedCustomerDetail,
    bool? isDetailLoading,
    String? errorMessage,
    DateTime? startDate,
    DateTime? endDate,
    String? name,
    String? status,
    bool clearError = false,
    bool clearFilter = false,
    bool clearSelectedDetail = false,
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
      selectedCustomerDetail: clearSelectedDetail
          ? null
          : (selectedCustomerDetail ?? this.selectedCustomerDetail),
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
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

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> loadBillings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final billings = await _repository.getCustomerBillings(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        query: state.name.isNotEmpty ? state.name : null,
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

  Future<void> getCustomerBillingDetail(String customerName) async {
    state = state.copyWith(isDetailLoading: true, clearError: true);
    try {
      final detail = await _repository.getCustomerBillingDetail(customerName);
      state = state.copyWith(
        isDetailLoading: false,
        selectedCustomerDetail: detail,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isDetailLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    } catch (e) {
      state = state.copyWith(
        isDetailLoading: false,
        errorMessage: 'Terjadi kesalahan: $e',
      );
    }
  }

  void clearSelectedCustomer() {
    state = state.copyWith(clearSelectedDetail: true);
  }

  Future<void> applyAdvanceFilter({
    DateTime? startDate,
    DateTime? endDate,
    String? name,
    String? status,
  }) async {
    _lastFetchTime = null;
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      name: name ?? '',
      status: status ?? '',
    );
    await loadBillings();
  }

  Future<void> resetFilter() async {
    _lastFetchTime = null;
    state = state.copyWith(clearFilter: true);
    await loadBillings();
  }

  Future<void> loadIfNeeded() async {
    if (!_isCacheExpired && !state.hasActiveFilter) return;
    await loadBillings();
  }

  Future<void> refresh() async {
    _lastFetchTime = null;
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      final billings = await _repository.getCustomerBillings(
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

  void search(String query) {
    _lastQuery = query;

    if (query.isEmpty) {
      _debounceTimer?.cancel();
      state = state.copyWith(
        name: '',
        filteredBillings: List.from(state.billings),
      );
      return;
    }

    state = state.copyWith(
      filteredBillings: _filterAndSort(state.billings, query),
    );

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      state = state.copyWith(name: query);
      _searchFromApi();
    });
  }

  Future<void> _searchFromApi() async {
    try {
      final billings = await _repository.getCustomerBillings(
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        query: state.name,
        status: state.status.isNotEmpty ? state.status : null,
      );
      if (_lastQuery != state.name) return;

      state = state.copyWith(
        filteredBillings: _filterAndSort(billings, state.name),
      );
    } on Exception catch (_) {}
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

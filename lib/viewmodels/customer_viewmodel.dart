import 'package:flutter_riverpod/legacy.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/customer_repository.dart';

class CustomerState {
  final bool isLoading;
  final bool isRefreshing;
  final bool isSubmitting; // ← loading khusus tambah/hapus
  final List<CustomerModel> customers;
  final List<CustomerModel> filteredCustomers;
  final String? errorMessage;
  final String? successMessage;

  const CustomerState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isSubmitting = false,
    this.customers = const [],
    this.filteredCustomers = const [],
    this.errorMessage,
    this.successMessage,
  });

  CustomerState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isSubmitting,
    List<CustomerModel>? customers,
    List<CustomerModel>? filteredCustomers,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return CustomerState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class CustomerViewModel extends StateNotifier<CustomerState> {
  final CustomerRepository _repository;

  CustomerViewModel(this._repository) : super(const CustomerState()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final customers = await _repository.getCustomers();
      state = state.copyWith(
        isLoading: false,
        customers: customers,
        filteredCustomers: customers,
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
      final customers = await _repository.getCustomers();
      state = state.copyWith(
        isRefreshing: false,
        customers: customers,
        filteredCustomers: customers,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> addCustomer({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.addCustomer({
        'customer_name': name,
        'customer_email': email,
        'customer_phone': phone,
        'customer_address': address,
      });

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Konsumen berhasil ditambahkan',
      );

      await loadCustomers(); // refresh list setelah tambah
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.deleteCustomer(id);

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Konsumen berhasil dihapus',
      );

      await loadCustomers(); // refresh list setelah hapus
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateCustomer({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.updateCustomer(id, {
        'customer_name': name,
        'customer_email': email,
        'customer_phone': phone,
        'customer_address': address,
      });

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Konsumen berhasil diubah',
      );

      await loadCustomers(); // refresh list setelah update
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredCustomers: state.customers);
      return;
    }
    final keyword = query.toLowerCase();
    final filtered = state.customers.where((c) {
      return c.customerName.toLowerCase().contains(keyword) ||
          c.customerEmail.toLowerCase().contains(keyword) ||
          c.customerPhone.contains(keyword);
    }).toList();
    state = state.copyWith(filteredCustomers: filtered);
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  void clearFilteredCustomers() {
    state = state.copyWith(filteredCustomers: []);
    loadCustomers();
  }
}

final customerViewModelProvider =
    StateNotifierProvider<CustomerViewModel, CustomerState>((ref) {
      final repository = ref.watch(customerRepositoryProvider);
      return CustomerViewModel(repository);
    });

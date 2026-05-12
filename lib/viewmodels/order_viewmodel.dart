import 'package:flutter_riverpod/legacy.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_order_request_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/order_repository.dart';

class OrderState {
  final bool isLoading;
  final bool isRefreshing;
  final List<OrderModel> orders;
  final List<OrderModel> filteredOrders;
  final String? errorMessage;
  final bool isSubmitting;
  final int activeFilter;

  const OrderState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.orders = const [],
    this.filteredOrders = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.activeFilter = 0,
  });

  OrderState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<OrderModel>? orders,
    List<OrderModel>? filteredOrders,
    String? errorMessage,
    int? activeFilter,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      activeFilter: activeFilter ?? this.activeFilter,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class OrderViewModel extends StateNotifier<OrderState> {
  final OrderRepository _repository;

  OrderViewModel(this._repository) : super(const OrderState()) {
    loadOrders();
  }

  // Map index filter ke nilai order_status
  static const _filterStatus = {
    0: null, // semua
    1: 'pending',
    2: 'partial',
    3: 'shipped',
    4: 'completed',
  };

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final orders = await _repository.getOrders();
      state = state.copyWith(
        isLoading: false,
        orders: orders,
        filteredOrders: _applyFilter(orders, state.activeFilter),
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
      final orders = await _repository.getOrders();
      state = state.copyWith(
        isRefreshing: false,
        orders: orders,
        filteredOrders: _applyFilter(orders, state.activeFilter),
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> addOrder(AddOrderRequest request) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.addOrder(request);
      state = state.copyWith(isSubmitting: false);
      await loadOrders(); // refresh list setelah tambah
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Filter by status
  void setFilter(int index) {
    state = state.copyWith(
      activeFilter: index,
      filteredOrders: _applyFilter(state.orders, index),
    );
  }

  // Search by PO number atau nama penerima
  void search(String query) {
    final base = _applyFilter(state.orders, state.activeFilter);

    if (query.isEmpty) {
      state = state.copyWith(filteredOrders: base);
      return;
    }

    final keyword = query.toLowerCase();
    final filtered = base.where((o) {
      return o.poNo.toLowerCase().contains(keyword) ||
          o.recipientName.toLowerCase().contains(keyword) ||
          o.transactionNo.toLowerCase().contains(keyword);
    }).toList();

    state = state.copyWith(filteredOrders: filtered);
  }

  // Hit API → update lokal → instan tanpa refetch semua
  Future<bool> updateOrder(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      // 1. Hit API — dapat data terbaru dari server
      final updatedOrder = await _repository.updateOrder(id, data);

      // 2. Update lokal — ganti 1 item di list, tidak fetch ulang semua
      _updateOrderLocally(updatedOrder);

      state = state.copyWith(isSubmitting: false);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Ganti 1 order di list berdasarkan id
  void _updateOrderLocally(OrderModel updatedOrder) {
    final updatedList = state.orders.map((o) {
      return o.id == updatedOrder.id ? updatedOrder : o;
    }).toList();

    state = state.copyWith(
      orders: updatedList,
      filteredOrders: _applyFilter(updatedList, state.activeFilter),
    );
  }

  List<OrderModel> _applyFilter(List<OrderModel> orders, int filterIndex) {
    final status = _filterStatus[filterIndex];
    if (status == null) return orders; // tampil semua
    return orders.where((o) => o.orderStatus == status).toList();
  }
}

final orderViewModelProvider =
    StateNotifierProvider<OrderViewModel, OrderState>((ref) {
      final repository = ref.watch(orderRepositoryProvider);
      return OrderViewModel(repository);
    });

import 'package:flutter_riverpod/legacy.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_order_request_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/order_repository.dart';

class OrderState {
  final bool isLoading;
  final bool isRefreshing;
  final bool isSubmitting;
  final bool isLoadingTrxNo;
  final bool isRefreshingDetail;
  final List<OrderModel> orders;
  final List<OrderModel> filteredOrders;
  final String? errorMessage;
  final String? nextTransactionNo;
  final int activeFilter;

  const OrderState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isSubmitting = false,
    this.isLoadingTrxNo = false,
    this.isRefreshingDetail = false,
    this.orders = const [],
    this.filteredOrders = const [],
    this.errorMessage,
    this.nextTransactionNo,
    this.activeFilter = 0,
  });

  OrderState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isSubmitting,
    bool? isLoadingTrxNo,
    bool? isRefreshingDetail,
    List<OrderModel>? orders,
    List<OrderModel>? filteredOrders,
    String? errorMessage,
    String? nextTransactionNo,
    int? activeFilter,
    bool clearError = false,
    bool clearTrxNo = false,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingTrxNo: isLoadingTrxNo ?? this.isLoadingTrxNo,
      isRefreshingDetail: isRefreshingDetail ?? this.isRefreshingDetail,
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      nextTransactionNo: clearTrxNo
          ? null
          : (nextTransactionNo ?? this.nextTransactionNo),
      activeFilter: activeFilter ?? this.activeFilter,
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
      clearNextTransactionNo();
      await loadOrders();
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Ambil nomor transaksi berikutnya
  Future<void> fetchNextTransactionNo() async {
    state = state.copyWith(isLoadingTrxNo: true, clearError: true);
    try {
      final result = await _repository.getNextTransactionNo();
      state = state.copyWith(
        isLoadingTrxNo: false,
        nextTransactionNo: result.transactionNo,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoadingTrxNo: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // Reset nomor transaksi setelah order dibuat
  void clearNextTransactionNo() {
    state = state.copyWith(clearTrxNo: true);
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

  Future<OrderModel?> refreshDetail(String orderId) async {
    state = state.copyWith(isRefreshingDetail: true, clearError: true);
    try {
      final updatedOrder = await _repository.getOrderDetail(orderId);

      // Update juga di list agar konsisten
      _updateOrderLocally(updatedOrder);

      state = state.copyWith(isRefreshingDetail: false);
      return updatedOrder;
    } on Exception catch (e) {
      state = state.copyWith(
        isRefreshingDetail: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

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

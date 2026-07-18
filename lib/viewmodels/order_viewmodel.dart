import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_order_request_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/repositories/order_repository.dart';

class OrderState {
  final bool isLoading;
  final bool isLoadMore;
  final bool isRefreshing;
  final bool isSubmitting;
  final bool isRefreshingDetail;
  final bool isLoadingTrxNo;
  final List<OrderModel> orders;
  final List<OrderModel> filteredOrders;
  final int currentPage;
  final bool hasReachedMax;
  final String? errorMessage;
  final String? nextTransactionNo;
  final int activeFilter;
  final String searchQuery;

  final DateTime? startDate;
  final DateTime? endDate;
  final String poNo;
  final String recipientName;
  final String orderStatus;

  const OrderState({
    this.isLoading = false,
    this.isLoadMore = false,
    this.isRefreshing = false,
    this.isSubmitting = false,
    this.isRefreshingDetail = false,
    this.isLoadingTrxNo = false,
    this.orders = const [],
    this.filteredOrders = const [],
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.errorMessage,
    this.nextTransactionNo,
    this.activeFilter = 0,
    this.searchQuery = '',
    this.startDate,
    this.endDate,
    this.poNo = '',
    this.recipientName = '',
    this.orderStatus = '',
  });

  bool get hasActiveFilter =>
      startDate != null ||
      endDate != null ||
      poNo.isNotEmpty ||
      recipientName.isNotEmpty ||
      orderStatus.isNotEmpty;

  OrderState copyWith({
    bool? isLoading,
    bool? isLoadMore,
    bool? isRefreshing,
    bool? isSubmitting,
    bool? isRefreshingDetail,
    bool? isLoadingTrxNo,
    List<OrderModel>? orders,
    List<OrderModel>? filteredOrders,
    int? currentPage,
    bool? hasReachedMax,
    String? errorMessage,
    String? nextTransactionNo,
    int? activeFilter,
    String? searchQuery,
    bool clearSearchQuery = false,
    DateTime? startDate,
    DateTime? endDate,
    String? poNo,
    String? recipientName,
    String? orderStatus,
    bool clearError = false,
    bool clearTrxNo = false,
    bool clearFilter = false,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      isLoadMore: isLoadMore ?? this.isLoadMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isRefreshingDetail: isRefreshingDetail ?? this.isRefreshingDetail,
      isLoadingTrxNo: isLoadingTrxNo ?? this.isLoadingTrxNo,
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      nextTransactionNo: clearTrxNo
          ? null
          : (nextTransactionNo ?? this.nextTransactionNo),
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: clearSearchQuery ? '' : (searchQuery ?? this.searchQuery),
      startDate: clearFilter ? null : (startDate ?? this.startDate),
      endDate: clearFilter ? null : (endDate ?? this.endDate),
      poNo: clearFilter ? '' : (poNo ?? this.poNo),
      recipientName: clearFilter ? '' : (recipientName ?? this.recipientName),
      orderStatus: clearFilter ? '' : (orderStatus ?? this.orderStatus),
    );
  }
}

class OrderViewModel extends StateNotifier<OrderState> {
  final OrderRepository _repository;

  Timer? _debounceTimer;
  DateTime? _lastFetchTime;

  static const _cacheDuration = Duration(minutes: 5);
  bool get _isCacheExpired =>
      _lastFetchTime == null ||
      DateTime.now().difference(_lastFetchTime!) > _cacheDuration;

  static const _filterStatus = {
    0: null,
    1: 'pending',
    2: 'partial',
    3: 'shipped',
    4: 'completed',
  };

  OrderViewModel(this._repository) : super(const OrderState()) {
    loadOrders();
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> loadOrders({bool isLoadMore = false}) async {
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
      final response = await _repository.getOrders(
        page: state.currentPage,
        limit: 20,
        searchQuery: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        poNo: state.poNo.isNotEmpty ? state.poNo : null,
        recipientName: state.recipientName.isNotEmpty
            ? state.recipientName
            : null,
        orderStatus: state.orderStatus.isNotEmpty ? state.orderStatus : null,
      );

      _lastFetchTime = DateTime.now();

      final newOrders = response.data;
      final totalPages = response.pagination.totalPages;

      final currentList = isLoadMore
          ? List<OrderModel>.from(state.orders)
          : <OrderModel>[];
      currentList.addAll(newOrders);

      state = state.copyWith(
        isLoading: false,
        isLoadMore: false,
        orders: currentList,
        filteredOrders: _applyFilter(currentList, state.activeFilter),
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

  Future<void> loadIfNeeded() async {
    if (!_isCacheExpired && !state.hasActiveFilter) return;
    await loadOrders();
  }

  Future<void> refresh() async {
    _lastFetchTime = null;
    state = state.copyWith(
      isRefreshing: true,
      clearError: true,
      currentPage: 1,
      hasReachedMax: false,
    );
    try {
      final response = await _repository.getOrders(
        page: 1,
        limit: 20,
        startDate: _formatDate(state.startDate),
        endDate: _formatDate(state.endDate),
        poNo: state.poNo.isNotEmpty ? state.poNo : null,
        recipientName: state.recipientName.isNotEmpty
            ? state.recipientName
            : null,
        orderStatus: state.orderStatus.isNotEmpty ? state.orderStatus : null,
      );

      _lastFetchTime = DateTime.now();
      final newOrders = response.data;
      final totalPages = response.pagination.totalPages;

      state = state.copyWith(
        isRefreshing: false,
        orders: newOrders,
        filteredOrders: _applyFilter(newOrders, state.activeFilter),
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
    String? poNo,
    String? recipientName,
    String? orderStatus,
  }) async {
    _lastFetchTime = null;
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      poNo: poNo ?? '',
      recipientName: recipientName ?? '',
      orderStatus: orderStatus ?? '',
    );
    await loadOrders();
  }

  Future<void> resetFilter() async {
    _lastFetchTime = null;
    state = state.copyWith(clearFilter: true);
    await loadOrders();
  }

  void setFilter(int index) {
    state = state.copyWith(
      activeFilter: index,
      filteredOrders: _applyFilter(state.orders, index),
    );
  }

  void search(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      state = state.copyWith(clearSearchQuery: true);
      loadOrders();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      state = state.copyWith(searchQuery: query);
      loadOrders();
    });
  }

  List<OrderModel> _applyFilter(List<OrderModel> orders, int filterIndex) {
    final status = _filterStatus[filterIndex];

    return orders.where((o) {
      bool matchStatus = status == null || o.orderStatus == status;

      bool matchPo =
          state.poNo.isEmpty ||
          o.poNo.toLowerCase().contains(state.poNo.toLowerCase());

      bool matchName =
          state.recipientName.isEmpty ||
          o.recipientName.toLowerCase().contains(
            state.recipientName.toLowerCase(),
          );

      if (state.recipientName.isNotEmpty && state.poNo.isEmpty) {
        final keyword = state.recipientName.toLowerCase();
        matchName =
            o.recipientName.toLowerCase().contains(keyword) ||
            o.poNo.toLowerCase().contains(keyword);
      }

      return matchStatus && matchPo && matchName;
    }).toList();
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

  void clearNextTransactionNo() {
    state = state.copyWith(clearTrxNo: true);
  }

  Future<bool> updateOrder(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final updatedOrder = await _repository.updateOrder(id, data);
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

  Future<OrderDetailModel?> getOrderDetail(String orderId) async {
    state = state.copyWith(isRefreshingDetail: true, clearError: true);
    try {
      final updatedOrder = await _repository.getOrderDetail(orderId);
      _updateOrderLocally(
        OrderModel(
          id: updatedOrder.id,
          poNo: updatedOrder.poNo,
          orderDate: updatedOrder.orderDate,
          recipientName: updatedOrder.recipientName,
          orderStatus: updatedOrder.orderStatus,
          totalAmountToPay: updatedOrder.totalAmountToPay,
        ),
      );
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

  Future<bool> deleteOrder(String id) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await _repository.deleteOrder(id);

      final updatedOrders = state.orders.where((o) => o.id != id).toList();
      final updatedFiltered = state.filteredOrders
          .where((o) => o.id != id)
          .toList();

      state = state.copyWith(
        isSubmitting: false,
        orders: updatedOrders,
        filteredOrders: updatedFiltered,
      );

      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
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
}

final orderViewModelProvider =
    StateNotifierProvider<OrderViewModel, OrderState>((ref) {
      final repository = ref.watch(orderRepositoryProvider);
      return OrderViewModel(repository);
    });

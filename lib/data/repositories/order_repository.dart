import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/app_strings.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_order_request_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/next_trx_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_response_model.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> getOrders({
    String? startDate,
    String? endDate,
    String? poNo,
    String? recipientName,
    String? orderStatus,
  });
  Future<OrderModel> updateOrder(String id, Map<String, dynamic> data);
  Future<void> addOrder(AddOrderRequest request);
  Future<NextTrxModel> getNextTransactionNo();
  Future<OrderModel> getOrderDetail(String orderId);
}

class OrderRepositoryImpl implements OrderRepository {
  final Dio _dio;

  OrderRepositoryImpl(this._dio);

  @override
  Future<List<OrderModel>> getOrders({
    String? startDate,
    String? endDate,
    String? poNo,
    String? recipientName,
    String? orderStatus,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (poNo != null) queryParams['po_no'] = poNo;
      if (recipientName != null) queryParams['recipient_name'] = recipientName;
      if (orderStatus != null) queryParams['order_status'] = orderStatus;

      final response = await _dio.get(
        '/orders',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final result = OrderResponseModel.fromJson(response.data);
      return result.data;
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Gagal memuat data pesanan');
    }
  }

  @override
  Future<void> addOrder(AddOrderRequest request) async {
    try {
      await _dio.post(AppStrings.ordersEndpoint, data: request.toJson());
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Gagal membuat pesanan');
    }
  }

  @override
  Future<OrderModel> updateOrder(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${AppStrings.ordersEndpoint}/$id',
        data: data,
      );

      return OrderModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Gagal mengubah pesanan');
    }
  }

  @override
  Future<NextTrxModel> getNextTransactionNo() async {
    try {
      final response = await _dio.get('${AppStrings.ordersEndpoint}/next-trx');
      return NextTrxModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Gagal mengambil nomor transaksi');
    }
  }

  @override
  Future<OrderModel> getOrderDetail(String orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');
      return OrderModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Gagal memuat detail pesanan');
    }
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return OrderRepositoryImpl(dio);
});

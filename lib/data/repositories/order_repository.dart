import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/app_strings.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/add_order_request_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_response_model.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> updateOrder(String id, Map<String, dynamic> data);
  Future<void> addOrder(AddOrderRequest request);
}

class OrderRepositoryImpl implements OrderRepository {
  final Dio _dio;

  OrderRepositoryImpl(this._dio);

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _dio.get(AppStrings.ordersEndpoint);
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
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return OrderRepositoryImpl(dio);
});

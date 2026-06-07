import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/app_strings.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_response_model.dart';

abstract class CustomerRepository {
  Future<List<CustomerModel>> getCustomers();
  Future<void> addCustomer(Map<String, dynamic> data);
  Future<void> deleteCustomer(String id);
  Future<void> updateCustomer(String id, Map<String, dynamic> data);
}

class CustomerRepositoryImpl implements CustomerRepository {
  final Dio _dio;

  CustomerRepositoryImpl(this._dio);

  @override
  Future<List<CustomerModel>> getCustomers() async {
    try {
      final response = await _dio.get(AppStrings.customersEndpoint);
      final result = CustomerResponseModel.fromJson(response.data);
      return result.data;
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Gagal memuat data customer');
    }
  }

  @override
  Future<void> addCustomer(Map<String, dynamic> data) async {
    try {
      await _dio.post(AppStrings.customersEndpoint, data: data);
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Gagal menambah konsumen');
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _dio.delete('${AppStrings.customersEndpoint}/$id');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Gagal menghapus konsumen');
    }
  }

  @override
  Future<void> updateCustomer(String id, Map<String, dynamic> data) async {
    try {
      await _dio.put('${AppStrings.customersEndpoint}/$id', data: data);
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Gagal mengubah data konsumen');
    }
  }
}

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CustomerRepositoryImpl(dio);
});

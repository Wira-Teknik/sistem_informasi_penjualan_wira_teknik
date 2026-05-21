import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_recap_detail_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_recap_model.dart';

abstract class PaymentRecapRepository {
  Future<PaymentRecapModel> getRecap({
    String? startDate,
    String? endDate,
    String? search,
  });

  Future<PaymentRecapDetailPendapatanModel> getDetailPendapatan({
    String? startDate,
    String? endDate,
    String? search,
  });

  Future<PaymentRecapDetailPesananModel> getDetailPesanan({
    String? startDate,
    String? endDate,
    String? search,
  });

  Future<PaymentRecapDetailUnpaidModel> getDetailUnpaid({
    String? startDate,
    String? endDate,
    String? search,
  });

  Future<PaymentRecapDetailPaidModel> getDetailPaid({
    String? startDate,
    String? endDate,
    String? search,
  });
}

class PaymentRecapRepositoryImpl implements PaymentRecapRepository {
  final Dio _dio;

  PaymentRecapRepositoryImpl(this._dio);

  @override
  Future<PaymentRecapModel> getRecap({
    String? startDate,
    String? endDate,
    String? search,
  }) async {
    try {
      // Hanya kirim parameter yang tidak kosong
      final queryParams = <String, dynamic>{};
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        '/payment-recap',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return PaymentRecapModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('ERROR RECAP: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat rekapitulasi pembayaran');
    }
  }

  @override
  Future<PaymentRecapDetailPendapatanModel> getDetailPendapatan({
    String? startDate,
    String? endDate,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        '/payment-recap/detail-pendapatan',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return PaymentRecapDetailPendapatanModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('ERROR DETAIL PENDAPATAN: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat detail pendapatan');
    }
  }

  @override
  Future<PaymentRecapDetailPesananModel> getDetailPesanan({
    String? startDate,
    String? endDate,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        '/payment-recap/detail-pesanan',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return PaymentRecapDetailPesananModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('ERROR DETAIL PESANAN: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat detail pesanan');
    }
  }

  @override
  Future<PaymentRecapDetailUnpaidModel> getDetailUnpaid({
    String? startDate,
    String? endDate,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        '/payment-recap/detail-unpaid',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return PaymentRecapDetailUnpaidModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('ERROR DETAIL UNPAID: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat detail unpaid');
    }
  }

  @override
  Future<PaymentRecapDetailPaidModel> getDetailPaid({
    String? startDate,
    String? endDate,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        '/payment-recap/detail-paid',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return PaymentRecapDetailPaidModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('ERROR DETAIL PAID: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat detail paid');
    }
  }
}

final paymentRecapRepositoryProvider = Provider<PaymentRecapRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentRecapRepositoryImpl(dio);
});

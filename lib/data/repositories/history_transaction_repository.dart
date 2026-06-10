import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/response/history_transaction_response_model.dart';

abstract class HistoryTransactionRepository {
  Future<HistoryTransactionResponseModel> getHistory({
    int? page,
    int? limit,
    String? search,
    String? startDate,
    String? endDate,
    String? status,
  });
  Future<String> exportHistoryTransaction({
    required String endpoint,
    String? search,
    String? status,
    String? startDate,
    String? endDate,
    required String fileName,
  });
}

class HistoryTransactionRepositoryImpl implements HistoryTransactionRepository {
  final Dio _dio;

  HistoryTransactionRepositoryImpl(this._dio);

  @override
  Future<HistoryTransactionResponseModel> getHistory({
    int? page,
    int? limit,
    String? search,
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/payments/history',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final result = HistoryTransactionResponseModel.fromJson(response.data);

      return result;
    } on DioException catch (e) {
      debugPrint('ERROR HISTORY: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat riwayat transaksi');
    }
  }

  @override
  Future<String> exportHistoryTransaction({
    required String endpoint,
    String? search,
    String? status,
    String? startDate,
    String? endDate,
    required String fileName,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';

      await _dio
          .get(
            endpoint,
            queryParameters: queryParams.isNotEmpty ? queryParams : null,
            options: Options(
              responseType: ResponseType.bytes,
              receiveTimeout: const Duration(minutes: 2),
            ),
          )
          .then((response) async {
            final file = File(filePath);
            await file.writeAsBytes(response.data);
          });

      return filePath;
    } on DioException catch (e) {
      debugPrint('ERROR EXPORT: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal mengunduh file');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}

final historyTransactionRepositoryProvider =
    Provider<HistoryTransactionRepository>((ref) {
      final dio = ref.watch(dioProvider);
      return HistoryTransactionRepositoryImpl(dio);
    });

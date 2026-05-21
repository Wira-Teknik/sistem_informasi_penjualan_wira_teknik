import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/history_transaction_model.dart';

abstract class HistoryTransactionRepository {
  Future<List<HistoryTransactionModel>> getHistory({String? query});
}

class HistoryTransactionRepositoryImpl implements HistoryTransactionRepository {
  final Dio _dio;

  HistoryTransactionRepositoryImpl(this._dio);

  @override
  Future<List<HistoryTransactionModel>> getHistory({String? query}) async {
    try {
      final response = await _dio.get(
        '/orders/history',
        queryParameters: query != null && query.isNotEmpty
            ? {'q': query}
            : null,
      );
      final result = HistoryTransactionResponseModel.fromJson(response.data);
      return result.data;
    } on DioException catch (e) {
      debugPrint('ERROR HISTORY: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat riwayat transaksi');
    }
  }
}

final historyTransactionRepositoryProvider =
    Provider<HistoryTransactionRepository>((ref) {
      final dio = ref.watch(dioProvider);
      return HistoryTransactionRepositoryImpl(dio);
    });

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/app_strings.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/audit_model.dart';

abstract class AuditRepository {
  Future<List<AuditModel>> getAudit({String? query});
}

class AuditRepositoryImpl implements AuditRepository {
  final Dio _dio;

  AuditRepositoryImpl(this._dio);

  @override
  Future<List<AuditModel>> getAudit({String? query}) async {
    try {
      final response = await _dio.get(
        AppStrings.auditEndpoint,
        queryParameters: query != null && query.isNotEmpty
            ? {'name': query}
            : null,
      );
      final result = AuditResponseModel.fromJson(response.data);
      return result.data;
    } on DioException catch (e) {
      debugPrint('ERROR AUDIT: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat data audit');
    }
  }
}

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuditRepositoryImpl(dio);
});

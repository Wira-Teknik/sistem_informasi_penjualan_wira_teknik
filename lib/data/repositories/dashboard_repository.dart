import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/app_strings.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/dashboard_model.dart';

abstract class DashboardRepository {
  Future<DashboardMetricsModel> getDashboard();
}

class DashboardRepositoryImpl implements DashboardRepository {
  final Dio _dio;

  DashboardRepositoryImpl(this._dio);

  @override
  Future<DashboardMetricsModel> getDashboard() async {
    try {
      final response = await _dio.get(AppStrings.dashboardEndpoint);

      return DashboardMetricsModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('ERROR DASHBOARD: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat data dashboard');
    }
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardRepositoryImpl(dio);
});

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/app_strings.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/response/dashboard_activities_response_model.dart';

abstract class ActivityRepository {
  Future<DashboardActivitiesResponseModel> getAllActivities({
    int? page,
    int? limit,
    String? startDate,
    String? endDate,
  });
}

class ActivityRepositoryImpl implements ActivityRepository {
  final Dio _dio;

  ActivityRepositoryImpl(this._dio);

  @override
  Future<DashboardActivitiesResponseModel> getAllActivities({
    int? page,
    int? limit,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
      }

      final response = await _dio.get(
        '${AppStrings.dashboardEndpoint}/activities',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return DashboardActivitiesResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('ERROR ACTIVITIES: ${e.response?.data}');
      throw Exception(e.error ?? 'Gagal memuat aktivitas');
    }
  }
}

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ActivityRepositoryImpl(dio);
});

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/dio_client.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/activity_response_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/dashboard_model.dart';

abstract class ActivityRepository {
  Future<List<ActivityModel>> getAllActivities();
}

class ActivityRepositoryImpl implements ActivityRepository {
  final Dio _dio;

  ActivityRepositoryImpl(this._dio);

  @override
  Future<List<ActivityModel>> getAllActivities() async {
    try {
      final response = await _dio.get('/dashboard/activities');
      final result = ActivityResponseModel.fromJson(response.data);
      return result.data;
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

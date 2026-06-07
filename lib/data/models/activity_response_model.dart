import 'package:sistem_informasi_penjualan_wira_teknik/data/models/dashboard_model.dart';

class ActivityResponseModel {
  final bool success;
  final String message;
  final List<ActivityModel> data;

  const ActivityResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ActivityResponseModel.fromJson(Map<String, dynamic> json) =>
      ActivityResponseModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: (json['data'] as List? ?? [])
            .map((e) => ActivityModel.fromJson(e))
            .toList(),
      );
}

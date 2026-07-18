import 'package:sistem_informasi_penjualan_wira_teknik/data/models/dashboard_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/pagination_model.dart';

class DashboardActivitiesResponseModel {
  final bool success;
  final String message;
  final List<DashboardActivityItemModel> data;
  final PaginationModel? pagination;

  const DashboardActivitiesResponseModel({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory DashboardActivitiesResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => DashboardActivitiesResponseModel(
    success: json['success'] ?? false,
    message: json['message'] ?? '',
    data: json['data'] != null
        ? (json['data'] as List)
              .map((e) => DashboardActivityItemModel.fromJson(e))
              .toList()
        : [],
    pagination: json['pagination'] != null
        ? PaginationModel.fromJson(json['pagination'])
        : null,
  );
}

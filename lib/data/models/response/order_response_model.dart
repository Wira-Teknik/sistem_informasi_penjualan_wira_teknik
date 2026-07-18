import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/pagination_model.dart';

class OrderResponseModel {
  final bool success;
  final String message;
  final List<OrderModel> data;
  final PaginationModel pagination;

  const OrderResponseModel({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) =>
      OrderResponseModel(
        success: json['success'],
        message: json['message'],
        data: (json['data'] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList(),
        pagination: PaginationModel.fromJson(json['pagination']),
      );
}

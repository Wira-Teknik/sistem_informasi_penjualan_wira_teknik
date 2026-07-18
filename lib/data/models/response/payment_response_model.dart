import 'package:sistem_informasi_penjualan_wira_teknik/data/models/pagination_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_model.dart';

class PaymentResponseModel {
  final bool success;
  final String message;
  final List<PaymentModel> data;
  final PaginationModel pagination;

  const PaymentResponseModel({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) =>
      PaymentResponseModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: (json['data'] as List? ?? [])
            .map((e) => PaymentModel.fromJson(e))
            .toList(),
        pagination: PaginationModel.fromJson(json['pagination']),
      );
}

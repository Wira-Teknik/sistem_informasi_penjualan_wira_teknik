import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/pagination_model.dart';

class CustomerBillingResponseModel {
  final bool success;
  final String message;
  final List<CustomerBillingModel> data;
  final PaginationModel pagination;

  const CustomerBillingResponseModel({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory CustomerBillingResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerBillingResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
                .map((e) => CustomerBillingModel.fromJson(e))
                .toList()
          : [],
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }
}

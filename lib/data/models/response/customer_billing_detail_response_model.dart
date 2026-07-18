import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_detail_model.dart';

class CustomerBillingDetailResponseModel {
  final bool success;
  final String message;
  final CustomerBillingDetailModel data;

  const CustomerBillingDetailResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CustomerBillingDetailResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CustomerBillingDetailResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CustomerBillingDetailModel.fromJson(json['data'] ?? {}),
    );
  }
}

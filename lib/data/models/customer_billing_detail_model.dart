import 'package:sistem_informasi_penjualan_wira_teknik/data/models/customer_billing_model.dart';

class CustomerBillingDetailModel {
  final String customerName;
  final int remainingBalance;
  final List<BillingOrderModel> orders;

  const CustomerBillingDetailModel({
    required this.customerName,
    required this.remainingBalance,
    required this.orders,
  });

  factory CustomerBillingDetailModel.fromJson(Map<String, dynamic> json) {
    return CustomerBillingDetailModel(
      customerName: json['customer_name'] ?? '',
      remainingBalance: json['remaining_balance'] ?? 0,
      orders: json['orders'] != null
          ? (json['orders'] as List)
                .map((e) => BillingOrderModel.fromJson(e))
                .toList()
          : [],
    );
  }
}

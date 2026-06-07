import 'order_model.dart';

class CustomerBillingModel {
  final String customerName;
  final List<OrderModel> orders;
  final int totalTagihan;

  const CustomerBillingModel({
    required this.customerName,
    required this.orders,
    required this.totalTagihan,
  });

  factory CustomerBillingModel.fromJson(Map<String, dynamic> json) =>
      CustomerBillingModel(
        customerName: json['customer_name'] ?? '',
        orders: (json['orders'] as List? ?? [])
            .map((e) => OrderModel.fromJson(e))
            .toList(),
        totalTagihan: json['total_tagihan'] ?? 0,
      );
}

class CustomerBillingResponseModel {
  final bool success;
  final String message;
  final List<CustomerBillingModel> data;

  const CustomerBillingResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CustomerBillingResponseModel.fromJson(Map<String, dynamic> json) =>
      CustomerBillingResponseModel(
        success: json['success'],
        message: json['message'],
        data: (json['data'] as List? ?? [])
            .map((e) => CustomerBillingModel.fromJson(e))
            .toList(),
      );
}

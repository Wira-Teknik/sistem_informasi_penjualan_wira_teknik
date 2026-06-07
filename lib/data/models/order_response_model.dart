import 'order_model.dart';

class OrderResponseModel {
  final bool success;
  final String message;
  final List<OrderModel> data;

  const OrderResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) =>
      OrderResponseModel(
        success: json['success'],
        message: json['message'],
        data: (json['data'] as List)
            .map((e) => OrderModel.fromJson(e))
            .toList(),
      );
}

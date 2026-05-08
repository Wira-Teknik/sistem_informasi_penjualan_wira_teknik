import 'customer_model.dart';

class CustomerResponseModel {
  final bool success;
  final String message;
  final List<CustomerModel> data;

  const CustomerResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) =>
      CustomerResponseModel(
        success: json['success'],
        message: json['message'],
        data: (json['data'] as List)
            .map((item) => CustomerModel.fromJson(item))
            .toList(),
      );
}

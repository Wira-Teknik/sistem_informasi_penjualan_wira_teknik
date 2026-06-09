import 'package:sistem_informasi_penjualan_wira_teknik/data/models/order_model.dart';

class OrderDetailResponseModel {
  final bool success;
  final OrderDetailModel data;

  const OrderDetailResponseModel({required this.success, required this.data});

  factory OrderDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponseModel(
      success: json['success'] ?? false,
      // Mengambil objek data
      data: OrderDetailModel.fromJson(json['data'] ?? {}),
    );
  }
}

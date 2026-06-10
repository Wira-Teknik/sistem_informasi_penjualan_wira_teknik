import 'package:sistem_informasi_penjualan_wira_teknik/data/models/pagination_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_recap_detail_model.dart';

class PaymentRecapDetailPendapatanResponseModel {
  final bool success;
  final String message;
  final PaymentRecapDetailPendapatanModel? data;
  final PaginationModel? pagination;

  const PaymentRecapDetailPendapatanResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.pagination,
  });

  factory PaymentRecapDetailPendapatanResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => PaymentRecapDetailPendapatanResponseModel(
    success: json['success'] ?? false,
    message: json['message'] ?? '',
    data: json['data'] != null
        ? PaymentRecapDetailPendapatanModel.fromJson(json['data'])
        : null,
    pagination: json['pagination'] != null
        ? PaginationModel.fromJson(json['pagination'])
        : null,
  );
}

class PaymentRecapDetailPesananResponseModel {
  final bool success;
  final String message;
  final PaymentRecapDetailPesananModel? data;
  final PaginationModel? pagination;

  const PaymentRecapDetailPesananResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.pagination,
  });

  factory PaymentRecapDetailPesananResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => PaymentRecapDetailPesananResponseModel(
    success: json['success'] ?? false,
    message: json['message'] ?? '',
    data: json['data'] != null
        ? PaymentRecapDetailPesananModel.fromJson(json['data'])
        : null,
    pagination: json['pagination'] != null
        ? PaginationModel.fromJson(json['pagination'])
        : null,
  );
}

class PaymentRecapDetailUnpaidResponseModel {
  final bool success;
  final String message;
  final PaymentRecapDetailUnpaidModel? data;
  final PaginationModel? pagination;

  const PaymentRecapDetailUnpaidResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.pagination,
  });

  factory PaymentRecapDetailUnpaidResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => PaymentRecapDetailUnpaidResponseModel(
    success: json['success'] ?? false,
    message: json['message'] ?? '',
    data: json['data'] != null
        ? PaymentRecapDetailUnpaidModel.fromJson(json['data'])
        : null,
    pagination: json['pagination'] != null
        ? PaginationModel.fromJson(json['pagination'])
        : null,
  );
}

class PaymentRecapDetailPaidResponseModel {
  final bool success;
  final String message;
  final PaymentRecapDetailPaidModel? data;
  final PaginationModel? pagination;

  const PaymentRecapDetailPaidResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.pagination,
  });

  factory PaymentRecapDetailPaidResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => PaymentRecapDetailPaidResponseModel(
    success: json['success'] ?? false,
    message: json['message'] ?? '',
    data: json['data'] != null
        ? PaymentRecapDetailPaidModel.fromJson(json['data'])
        : null,
    pagination: json['pagination'] != null
        ? PaginationModel.fromJson(json['pagination'])
        : null,
  );
}

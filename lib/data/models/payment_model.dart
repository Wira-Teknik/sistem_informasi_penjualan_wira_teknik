class PaymentDetailModel {
  final String id;
  final String invoiceId;
  final String paymentId;
  final double allocatedAmount;
  final String createdAt;
  final String updatedAt;

  const PaymentDetailModel({
    required this.id,
    required this.invoiceId,
    required this.paymentId,
    required this.allocatedAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentDetailModel.fromJson(Map<String, dynamic> json) =>
      PaymentDetailModel(
        id: json['id'] ?? '',
        invoiceId: json['invoice_id'] ?? '',
        paymentId: json['payment_id'] ?? '',
        allocatedAmount: (json['allocated_amount'] as num? ?? 0).toDouble(),
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'invoice_id': invoiceId,
    'payment_id': paymentId,
    'allocated_amount': allocatedAmount,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class PaymentModel {
  final String id;
  final String paymentDate;
  final double paymentTotal;
  final List<PaymentDetailModel> details;
  final String createdAt;
  final String updatedAt;

  const PaymentModel({
    required this.id,
    required this.paymentDate,
    required this.paymentTotal,
    required this.details,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json['id'] ?? '',
    paymentDate: json['payment_date'] ?? '',
    paymentTotal: (json['payment_total'] as num? ?? 0).toDouble(),
    details: (json['details'] as List? ?? [])
        .map((e) => PaymentDetailModel.fromJson(e))
        .toList(),
    createdAt: json['created_at'] ?? '',
    updatedAt: json['updated_at'] ?? '',
  );

  PaymentModel copyWith({
    String? id,
    String? paymentDate,
    double? paymentTotal,
    List<PaymentDetailModel>? details,
    String? createdAt,
    String? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentTotal: paymentTotal ?? this.paymentTotal,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PaymentResponseModel {
  final bool success;
  final String message;
  final List<PaymentModel> data;

  const PaymentResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) =>
      PaymentResponseModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: (json['data'] as List? ?? [])
            .map((e) => PaymentModel.fromJson(e))
            .toList(),
      );
}

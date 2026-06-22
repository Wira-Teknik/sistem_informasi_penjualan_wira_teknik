class PaymentDetailModel {
  final String id;
  final String paymentId;
  final String invoiceId;
  final String invoiceNo;
  final int allocatedAmount;
  final String createdAt;
  final String updatedAt;

  const PaymentDetailModel({
    required this.id,
    required this.paymentId,
    required this.invoiceId,
    required this.invoiceNo,
    required this.allocatedAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentDetailModel.fromJson(Map<String, dynamic> json) =>
      PaymentDetailModel(
        id: json['id'] ?? '',
        paymentId: json['payment_id'] ?? '',
        invoiceId: json['invoice_id'] ?? '',
        invoiceNo: json['invoice_no'] ?? '',
        allocatedAmount: (json['allocated_amount'] as num? ?? 0).toInt(),
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'payment_id': paymentId,
    'invoice_id': invoiceId,
    'invoice_no': invoiceNo,
    'allocated_amount': allocatedAmount,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  PaymentDetailModel copyWith({
    String? id,
    String? paymentId,
    String? invoiceId,
    String? invoiceNo,
    int? allocatedAmount,
    String? createdAt,
    String? updatedAt,
  }) {
    return PaymentDetailModel(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PaymentModel {
  final String paymentId;
  final String paymentDate;
  final int allocatedAmount;
  final List<PaymentDetailModel> details;

  const PaymentModel({
    required this.paymentId,
    required this.paymentDate,
    required this.allocatedAmount,
    this.details = const [],
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    paymentId: json['payment_id'] ?? '',
    paymentDate: json['payment_date'] ?? '',
    allocatedAmount: (json['allocated_amount'] as num? ?? 0).toInt(),
    details:
        (json['details'] as List<dynamic>?)
            ?.map((e) => PaymentDetailModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );

  Map<String, dynamic> toJson() => {
    'payment_id': paymentId,
    'payment_date': paymentDate,
    'allocated_amount': allocatedAmount,
    'details': details.map((e) => e.toJson()).toList(),
  };

  PaymentModel copyWith({
    String? paymentId,
    String? paymentDate,
    int? allocatedAmount,
    List<PaymentDetailModel>? details,
  }) {
    return PaymentModel(
      paymentId: paymentId ?? this.paymentId,
      paymentDate: paymentDate ?? this.paymentDate,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      details: details ?? this.details,
    );
  }
}

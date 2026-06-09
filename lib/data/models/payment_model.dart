class PaymentModel {
  final String paymentId;
  final String paymentDate;
  final int allocatedAmount;

  const PaymentModel({
    required this.paymentId,
    required this.paymentDate,
    required this.allocatedAmount,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    paymentId: json['payment_id'] ?? '',
    paymentDate: json['payment_date'] ?? '',
    allocatedAmount: (json['allocated_amount'] as num? ?? 0).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'payment_id': paymentId,
    'payment_date': paymentDate,
    'allocated_amount': allocatedAmount,
  };

  PaymentModel copyWith({
    String? paymentId,
    String? paymentDate,
    int? allocatedAmount,
  }) {
    return PaymentModel(
      paymentId: paymentId ?? this.paymentId,
      paymentDate: paymentDate ?? this.paymentDate,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
    );
  }
}

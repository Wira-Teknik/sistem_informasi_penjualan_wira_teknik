class InvoiceModel {
  final String id;
  final String shipmentId;
  final String invoiceNo;
  final int totalAmount;
  final int remainingBalance;
  final String paymentStatus;

  const InvoiceModel({
    required this.id,
    required this.shipmentId,
    required this.invoiceNo,
    required this.totalAmount,
    required this.remainingBalance,
    required this.paymentStatus,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] ?? '',
      shipmentId: json['shipment_id'] ?? '',
      invoiceNo: json['invoice_no'] ?? '',
      totalAmount: (json['total_amount'] as num? ?? 0).toInt(),
      remainingBalance: (json['remaining_balance'] as num? ?? 0).toInt(),
      paymentStatus: json['payment_status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shipment_id': shipmentId,
      'invoice_no': invoiceNo,
      'total_amount': totalAmount,
      'remaining_balance': remainingBalance,
      'payment_status': paymentStatus,
    };
  }

  InvoiceModel copyWith({
    String? id,
    String? shipmentId,
    String? invoiceNo,
    int? totalAmount,
    int? remainingBalance,
    String? paymentStatus,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      shipmentId: shipmentId ?? this.shipmentId,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      totalAmount: totalAmount ?? this.totalAmount,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}

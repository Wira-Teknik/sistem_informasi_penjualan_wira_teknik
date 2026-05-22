import 'dart:io';

class AddPaymentDetailRequest {
  final String orderId;

  const AddPaymentDetailRequest({required this.orderId});

  Map<String, dynamic> toJson() => {'order_id': orderId};
}

class AddPaymentRequest {
  final String paymentDate;
  final double paymentTotal;
  final List<AddPaymentDetailRequest> details;
  final File buktiKirim;

  const AddPaymentRequest({
    required this.paymentDate,
    required this.paymentTotal,
    required this.details,
    required this.buktiKirim,
  });
}

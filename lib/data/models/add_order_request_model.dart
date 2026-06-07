class AddOrderItemRequest {
  final String productName;
  final int orderQty;
  final double unitPrice;

  const AddOrderItemRequest({
    required this.productName,
    required this.orderQty,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
    'product_name': productName,
    'order_qty': orderQty,
    'unit_price': unitPrice,
  };
}

class AddOrderRequest {
  final String transactionNumber;
  final String poNo;
  final String orderDate;
  final String recipientName;
  final String recipientEmail;
  final String recipientPhone;
  final String recipientAddress;
  final List<AddOrderItemRequest> items;

  const AddOrderRequest({
    required this.transactionNumber,
    required this.poNo,
    required this.orderDate,
    required this.recipientName,
    required this.recipientEmail,
    required this.recipientPhone,
    required this.recipientAddress,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'transaction_no': transactionNumber,
    'po_no': poNo,
    'order_date': orderDate,
    'recipient_name': recipientName,
    'recipient_address': recipientAddress,
    'recipient_phone': recipientPhone,
    'recipient_email': recipientEmail,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

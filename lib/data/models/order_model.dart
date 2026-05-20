class ShipmentItemModel {
  final String id;
  final String shipmentId;
  final String orderItemId;
  final int shippingQty;
  final String createdAt;
  final String updatedAt;

  const ShipmentItemModel({
    required this.id,
    required this.shipmentId,
    required this.orderItemId,
    required this.shippingQty,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShipmentItemModel.fromJson(Map<String, dynamic> json) =>
      ShipmentItemModel(
        id: json['id'],
        shipmentId: json['shipment_id'],
        orderItemId: json['order_item_id'],
        shippingQty: json['shipping_qty'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );
}

class ShipmentModel {
  final String id;
  final String orderId;
  final String shippingDate;
  final String? receivedDate;
  final String shippingStatus;
  final List<ShipmentItemModel> items;
  final String createdAt;
  final String updatedAt;

  const ShipmentModel({
    required this.id,
    required this.orderId,
    required this.shippingDate,
    this.receivedDate,
    required this.shippingStatus,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) => ShipmentModel(
    id: json['id'],
    orderId: json['order_id'],
    shippingDate: json['shipping_date'],
    receivedDate: json['received_date'],
    shippingStatus: json['shipping_status'],
    items: (json['items'] as List)
        .map((e) => ShipmentItemModel.fromJson(e))
        .toList(),
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );
}

class OrderItemModel {
  final String id;
  final String orderId;
  final String productName;
  final int orderQty;
  final int remainingQty;
  final double unitPrice;
  final double ppn;
  final double subtotal;
  final String createdAt;
  final String updatedAt;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productName,
    required this.orderQty,
    required this.remainingQty,
    required this.unitPrice,
    required this.ppn,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    id: json['id'],
    orderId: json['order_id'],
    productName: json['product_name'],
    orderQty: json['order_qty'],
    remainingQty: json['remaining_qty'],
    unitPrice: (json['unit_price'] as num).toDouble(),
    ppn: (json['ppn'] as num).toDouble(),
    subtotal: (json['subtotal'] as num).toDouble(),
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );
}

class OrderModel {
  final String id;
  final String poNo;
  final String transactionNo;
  final String orderDate;
  final String orderStatus;
  final String recipientName;
  final String recipientEmail;
  final String recipientPhone;
  final String recipientAddress;
  final List<OrderItemModel> items;
  final List<ShipmentModel> shipments;
  final int totalAmountToPay;
  final int remainingBalance;
  final String paymentStatus;
  final String createdAt;
  final String updatedAt;

  const OrderModel({
    required this.id,
    required this.poNo,
    required this.transactionNo,
    required this.orderDate,
    required this.orderStatus,
    required this.recipientName,
    required this.recipientEmail,
    required this.recipientPhone,
    required this.recipientAddress,
    required this.items,
    required this.shipments,
    required this.totalAmountToPay,
    required this.remainingBalance,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  // Total dari semua subtotal item
  double get totalAmount => items.fold(0, (sum, item) => sum + item.subtotal);

  // order_model.dart — tambah null safety sementara untuk debug
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      poNo: json['po_no'] ?? '',
      transactionNo: json['transaction_no'] ?? '',
      orderDate: json['order_date'] ?? '',
      orderStatus: json['order_status'] ?? '',
      recipientName: json['recipient_name'] ?? '',
      recipientEmail: json['recipient_email'] ?? '',
      recipientPhone: json['recipient_phone'] ?? '',
      recipientAddress: json['recipient_address'] ?? '',
      items:
          (json['items'] as List? ?? []) // ← null safety
              .map((e) => OrderItemModel.fromJson(e))
              .toList(),
      shipments:
          (json['shipments'] as List? ?? []) // ← null safety
              .map((e) => ShipmentModel.fromJson(e))
              .toList(),
      totalAmountToPay: json['total_amount_to_pay'] ?? 0,
      remainingBalance: json['remaining_balance'] ?? 0,
      paymentStatus: json['payment_status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

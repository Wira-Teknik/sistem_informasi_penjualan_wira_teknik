class ShipmentModel {
  final String id;
  final String orderId;
  final String shippingDate;
  final String? receivedDate; // Bisa null jika belum diterima
  final String shippingStatus;
  final List<ShipmentItemModel> items;

  const ShipmentModel({
    required this.id,
    required this.orderId,
    required this.shippingDate,
    this.receivedDate,
    required this.shippingStatus,
    required this.items,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['id'] ?? '',
      orderId: json['order_id'] ?? '',
      shippingDate: json['shipping_date'] ?? '',
      receivedDate:
          json['received_date'], // Langsung di-assign, membiarkan nilai null
      shippingStatus: json['shipping_status'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
                .map((e) => ShipmentItemModel.fromJson(e))
                .toList()
          : [],
    );
  }
}

class ShipmentItemModel {
  final String id;
  final String shipmentId;
  final String orderItemId;
  final int shippingQty;

  const ShipmentItemModel({
    required this.id,
    required this.shipmentId,
    required this.orderItemId,
    required this.shippingQty,
  });

  factory ShipmentItemModel.fromJson(Map<String, dynamic> json) {
    return ShipmentItemModel(
      id: json['id'] ?? '',
      shipmentId: json['shipment_id'] ?? '',
      orderItemId: json['order_item_id'] ?? '',
      shippingQty: json['shipping_qty'] ?? 0,
    );
  }
}

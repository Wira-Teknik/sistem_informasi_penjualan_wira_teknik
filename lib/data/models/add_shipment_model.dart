import 'dart:io';

class ShipmentItemRequest {
  final String orderItemId;
  final int shippingQty;

  const ShipmentItemRequest({
    required this.orderItemId,
    required this.shippingQty,
  });

  Map<String, dynamic> toJson() => {
    'order_item_id': orderItemId,
    'shipping_qty': shippingQty,
  };
}

class AddShipmentRequest {
  final String orderId;
  final String shippingDate;
  final List<ShipmentItemRequest> items;
  final File buktiKirim; // required
  final File suratJalan; // required
  final File bonPesanan; // required
  final File invoiceFile; // optional

  const AddShipmentRequest({
    required this.orderId,
    required this.shippingDate,
    required this.items,
    required this.buktiKirim,
    required this.suratJalan,
    required this.bonPesanan,
    required this.invoiceFile,
  });
}

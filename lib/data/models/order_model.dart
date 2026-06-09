import 'package:sistem_informasi_penjualan_wira_teknik/data/models/invoice_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/shipment_model.dart';

class OrderModel {
  final String id;
  final String poNo;
  final String orderDate;
  final String recipientName;
  final String orderStatus;
  final int totalAmountToPay;

  const OrderModel({
    required this.id,
    required this.poNo,
    required this.orderDate,
    required this.recipientName,
    required this.orderStatus,
    required this.totalAmountToPay,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      poNo: json['po_no'] ?? '',
      orderDate: json['order_date'] ?? '',
      recipientName: json['recipient_name'] ?? '',
      orderStatus: json['order_status'] ?? '',
      totalAmountToPay: json['total_amount_to_pay'] ?? 0,
    );
  }
}

class OrderItemModel {
  final String id;
  final String productName;
  final int orderQty;
  final int remainingQty;
  final int unitPrice;
  final int ppn;
  final int subtotal;

  const OrderItemModel({
    required this.id,
    required this.productName,
    required this.orderQty,
    required this.remainingQty,
    required this.unitPrice,
    required this.ppn,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? '',
      productName: json['product_name'] ?? '',
      orderQty: json['order_qty'] ?? 0,
      remainingQty: json['remaining_qty'] ?? 0,
      unitPrice: json['unit_price'] ?? 0,
      ppn: json['ppn'] ?? 0,
      subtotal: json['subtotal'] ?? 0,
    );
  }
}

class OrderDetailModel {
  final String id;
  final String transactionNo;
  final String poNo;
  final String orderDate;
  final String recipientName;
  final String recipientAddress;
  final String recipientPhone;
  final String recipientEmail;
  final String orderStatus;
  final List<OrderItemModel> items;
  final List<ShipmentModel> shipments;
  final List<InvoiceModel> invoices;
  final int totalAmountToPay;
  final int remainingBalance;
  final String paymentStatus;
  final List<PaymentModel> payments;
  final String updatedAt;

  const OrderDetailModel({
    required this.id,
    required this.transactionNo,
    required this.poNo,
    required this.orderDate,
    required this.recipientName,
    required this.recipientAddress,
    required this.recipientPhone,
    required this.recipientEmail,
    required this.orderStatus,
    required this.items,
    required this.shipments,
    required this.invoices,
    required this.totalAmountToPay,
    required this.remainingBalance,
    required this.paymentStatus,
    required this.payments,
    required this.updatedAt,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'] ?? '',
      transactionNo: json['transaction_no'] ?? '',
      poNo: json['po_no'] ?? '',
      orderDate: json['order_date'] ?? '',
      recipientName: json['recipient_name'] ?? '',
      recipientAddress: json['recipient_address'] ?? '',
      recipientPhone: json['recipient_phone'] ?? '',
      recipientEmail: json['recipient_email'] ?? '',
      orderStatus: json['order_status'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
                .map((e) => OrderItemModel.fromJson(e))
                .toList()
          : [],
      shipments: json['shipments'] != null
          ? (json['shipments'] as List)
                .map((e) => ShipmentModel.fromJson(e))
                .toList()
          : [],
      invoices: json['invoices'] != null
          ? (json['invoices'] as List)
                .map((e) => InvoiceModel.fromJson(e))
                .toList()
          : [],
      totalAmountToPay: json['total_amount_to_pay'] ?? 0,
      remainingBalance: json['remaining_balance'] ?? 0,
      paymentStatus: json['payment_status'] ?? '',
      payments: json['payments'] != null
          ? (json['payments'] as List)
                .map((e) => PaymentModel.fromJson(e))
                .toList()
          : [],
      updatedAt: '${json['updated_at'] ?? ''}',
    );
  }
}

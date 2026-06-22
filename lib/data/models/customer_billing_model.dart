import 'package:sistem_informasi_penjualan_wira_teknik/data/models/invoice_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/payment_model.dart';

class CustomerBillingModel {
  final String customerName;
  final int totalUnpaid;
  final int totalPaid;
  final int totalPartial;
  final int totalTagihan;

  const CustomerBillingModel({
    required this.customerName,
    required this.totalTagihan,
    required this.totalUnpaid,
    required this.totalPaid,
    required this.totalPartial,
  });

  factory CustomerBillingModel.fromJson(Map<String, dynamic> json) {
    return CustomerBillingModel(
      customerName: json['customer_name'] ?? '',
      totalUnpaid: json['total_unpaid'] ?? 0,
      totalPaid: json['total_paid'] ?? 0,
      totalPartial: json['total_partial'] ?? 0,
      totalTagihan: json['total_tagihan'] ?? 0,
    );
  }
}

class BillingOrderModel {
  final String id;
  final String transactionNo;
  final String poNo;
  final String orderDate;
  final int totalAmountToPay;
  final int remainingBalance;
  final String paymentStatus;
  final List<InvoiceModel> invoices;
  final int unpaidInvoiceTotal;
  final int unpaidInvoiceCount;
  final List<PaymentModel> payments;

  const BillingOrderModel({
    required this.id,
    required this.transactionNo,
    required this.poNo,
    required this.orderDate,
    required this.totalAmountToPay,
    required this.remainingBalance,
    required this.paymentStatus,
    required this.invoices,
    required this.unpaidInvoiceTotal,
    required this.unpaidInvoiceCount,
    required this.payments,
  });

  factory BillingOrderModel.fromJson(Map<String, dynamic> json) {
    return BillingOrderModel(
      id: json['id'] ?? '',
      transactionNo: json['transaction_no'] ?? '',
      poNo: json['po_no'] ?? '',
      orderDate: json['order_date'] ?? '',
      totalAmountToPay: (json['total_amount_to_pay'] as num?)?.toInt() ?? 0,
      remainingBalance: (json['remaining_balance'] as num?)?.toInt() ?? 0,
      paymentStatus: json['payment_status'] ?? '',
      invoices: json['invoices'] != null
          ? (json['invoices'] as List)
                .map((e) => InvoiceModel.fromJson(e))
                .toList()
          : [],
      unpaidInvoiceTotal: (json['unpaid_invoice_total'] as num?)?.toInt() ?? 0,
      unpaidInvoiceCount: (json['unpaid_invoice_count'] as num?)?.toInt() ?? 0,
      payments: json['payments'] != null
          ? (json['payments'] as List)
                .map((e) => PaymentModel.fromJson(e))
                .toList()
          : [],
    );
  }
}

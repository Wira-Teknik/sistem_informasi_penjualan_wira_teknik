class PaymentRecapDetailItemModel {
  final String poNo;
  final String customerName;
  final String date;
  final int totalAmount;
  final String paymentStatus;

  const PaymentRecapDetailItemModel({
    required this.poNo,
    required this.customerName,
    required this.date,
    required this.totalAmount,
    required this.paymentStatus,
  });

  factory PaymentRecapDetailItemModel.fromJson(Map<String, dynamic> json) =>
      PaymentRecapDetailItemModel(
        poNo: json['po_no'] ?? '',
        customerName: json['customer_name'] ?? '',
        date: json['date'] ?? '',
        totalAmount: json['total_amount'] ?? 0,
        paymentStatus: json['payment_status'] ?? '',
      );
}

class PaymentRecapDetailPesananItemModel {
  final String transactionNo;
  final String poNo;
  final String customerName;
  final String date;
  final int totalAmount;
  final String orderStatus;

  const PaymentRecapDetailPesananItemModel({
    required this.transactionNo,
    required this.poNo,
    required this.customerName,
    required this.date,
    required this.totalAmount,
    required this.orderStatus,
  });

  factory PaymentRecapDetailPesananItemModel.fromJson(
    Map<String, dynamic> json,
  ) => PaymentRecapDetailPesananItemModel(
    transactionNo: json['transaction_no'] ?? '',
    poNo: json['po_no'] ?? '',
    customerName: json['customer_name'] ?? '',
    date: json['date'] ?? '',
    totalAmount: json['total_amount'] ?? 0,
    orderStatus: json['order_status'] ?? '',
  );
}

class PaymentRecapDetailPendapatanModel {
  final int totalPendapatan;
  final int totalPesananCount;
  final List<PaymentRecapDetailItemModel> items;

  const PaymentRecapDetailPendapatanModel({
    required this.totalPendapatan,
    required this.totalPesananCount,
    required this.items,
  });

  factory PaymentRecapDetailPendapatanModel.fromJson(
    Map<String, dynamic> json,
  ) {
    // HAPUS pemanggilan json['data'] di sini. Langsung baca dari json.
    return PaymentRecapDetailPendapatanModel(
      totalPendapatan: json['total_pendapatan'] ?? 0,
      totalPesananCount: json['total_pesanan_count'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => PaymentRecapDetailItemModel.fromJson(e))
          .toList(),
    );
  }
}

class PaymentRecapDetailPesananModel {
  final int totalPesananAmount;
  final int totalPesananCount;
  final List<PaymentRecapDetailPesananItemModel> items;

  const PaymentRecapDetailPesananModel({
    required this.totalPesananAmount,
    required this.totalPesananCount,
    required this.items,
  });

  factory PaymentRecapDetailPesananModel.fromJson(Map<String, dynamic> json) =>
      PaymentRecapDetailPesananModel(
        totalPesananAmount: json['total_pesanan_amount'] ?? 0,
        totalPesananCount: json['total_pesanan_count'] ?? 0,
        items: json['items'] != null
            ? (json['items'] as List)
                  .map((e) => PaymentRecapDetailPesananItemModel.fromJson(e))
                  .toList()
            : [],
      );
}

class PaymentRecapDetailUnpaidModel {
  final int totalUnpaid;
  final int totalCount;
  final List<PaymentRecapDetailItemModel> items;

  const PaymentRecapDetailUnpaidModel({
    required this.totalUnpaid,
    required this.totalCount,
    required this.items,
  });

  factory PaymentRecapDetailUnpaidModel.fromJson(Map<String, dynamic> json) {
    // Langsung baca dari json
    return PaymentRecapDetailUnpaidModel(
      totalUnpaid: json['total_unpaid'] ?? 0,
      totalCount: json['total_count'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => PaymentRecapDetailItemModel.fromJson(e))
          .toList(),
    );
  }
}

class PaymentRecapDetailPaidModel {
  final int totalPaid;
  final int totalCount;
  final List<PaymentRecapDetailItemModel> items;

  const PaymentRecapDetailPaidModel({
    required this.totalPaid,
    required this.totalCount,
    required this.items,
  });

  factory PaymentRecapDetailPaidModel.fromJson(Map<String, dynamic> json) {
    // Langsung baca dari json
    return PaymentRecapDetailPaidModel(
      totalPaid: json['total_paid'] ?? 0,
      totalCount: json['total_count'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => PaymentRecapDetailItemModel.fromJson(e))
          .toList(),
    );
  }
}

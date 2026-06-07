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
    final data = json['data'] as Map<String, dynamic>;
    return PaymentRecapDetailPendapatanModel(
      totalPendapatan: data['total_pendapatan'] ?? 0,
      totalPesananCount: data['total_pesanan_count'] ?? 0,
      items: (data['items'] as List? ?? [])
          .map((e) => PaymentRecapDetailItemModel.fromJson(e))
          .toList(),
    );
  }
}

class PaymentRecapDetailPesananItemModel {
  final String poNo;
  final String customerName;
  final String date;
  final int totalAmount;
  final String orderStatus;

  const PaymentRecapDetailPesananItemModel({
    required this.poNo,
    required this.customerName,
    required this.date,
    required this.totalAmount,
    required this.orderStatus,
  });

  factory PaymentRecapDetailPesananItemModel.fromJson(
    Map<String, dynamic> json,
  ) => PaymentRecapDetailPesananItemModel(
    poNo: json['po_no'] ?? '',
    customerName: json['customer_name'] ?? '',
    date: json['date'] ?? '',
    totalAmount: json['total_amount'] ?? 0,
    orderStatus: json['order_status'] ?? '',
  );
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

  factory PaymentRecapDetailPesananModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return PaymentRecapDetailPesananModel(
      totalPesananAmount: data['total_pesanan_amount'] ?? 0,
      totalPesananCount: data['total_pesanan_count'] ?? 0,
      items: (data['items'] as List? ?? [])
          .map((e) => PaymentRecapDetailPesananItemModel.fromJson(e))
          .toList(),
    );
  }
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
    final data = json['data'] as Map<String, dynamic>;
    return PaymentRecapDetailUnpaidModel(
      totalUnpaid: data['total_unpaid'] ?? 0,
      totalCount: data['total_count'] ?? 0,
      items: (data['items'] as List? ?? [])
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
    final data = json['data'] as Map<String, dynamic>;
    return PaymentRecapDetailPaidModel(
      totalPaid: data['total_paid'] ?? 0,
      totalCount: data['total_count'] ?? 0,
      items: (data['items'] as List? ?? [])
          .map((e) => PaymentRecapDetailItemModel.fromJson(e))
          .toList(),
    );
  }
}

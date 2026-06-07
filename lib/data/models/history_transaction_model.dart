class HistoryTransactionModel {
  final String id;
  final String transactionNo;
  final String poNo;
  final String customerName;
  final String adminName;
  final String createdAt;
  final int totalAmount;
  final String paymentStatus;

  const HistoryTransactionModel({
    required this.id,
    required this.transactionNo,
    required this.poNo,
    required this.customerName,
    required this.adminName,
    required this.createdAt,
    required this.totalAmount,
    required this.paymentStatus,
  });

  factory HistoryTransactionModel.fromJson(Map<String, dynamic> json) =>
      HistoryTransactionModel(
        id: json['id'] ?? '',
        transactionNo: json['transaction_no'] ?? '',
        poNo: json['po_no'] ?? '',
        customerName: json['customer_name'] ?? '',
        adminName: json['admin_name'] ?? '',
        createdAt: json['created_at'] ?? '',
        totalAmount: json['total_amount'] ?? 0,
        paymentStatus: json['payment_status'] ?? '',
      );
}

class HistoryTransactionResponseModel {
  final bool success;
  final String message;
  final List<HistoryTransactionModel> data;

  const HistoryTransactionResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory HistoryTransactionResponseModel.fromJson(Map<String, dynamic> json) =>
      HistoryTransactionResponseModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: (json['data'] as List? ?? [])
            .map((e) => HistoryTransactionModel.fromJson(e))
            .toList(),
      );
}

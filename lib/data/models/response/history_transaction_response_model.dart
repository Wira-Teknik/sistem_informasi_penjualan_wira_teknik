import 'package:sistem_informasi_penjualan_wira_teknik/data/models/history_transaction_model.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/pagination_model.dart';

class HistoryTransactionResponseModel {
  final bool success;
  final String message;
  final List<HistoryTransactionModel> data;
  final PaginationModel pagination;

  const HistoryTransactionResponseModel({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory HistoryTransactionResponseModel.fromJson(Map<String, dynamic> json) =>
      HistoryTransactionResponseModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: (json['data'] as List? ?? [])
            .map((e) => HistoryTransactionModel.fromJson(e))
            .toList(),
        pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
      );
}

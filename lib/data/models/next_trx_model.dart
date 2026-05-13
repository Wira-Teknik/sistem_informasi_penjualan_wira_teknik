class NextTrxModel {
  final String transactionNo;

  const NextTrxModel({required this.transactionNo});

  factory NextTrxModel.fromJson(Map<String, dynamic> json) =>
      NextTrxModel(transactionNo: json['data']['transaction_no']);
}

class PaymentRecapModel {
  final int totalPendapatan;
  final int totalPesananCount;
  final int totalUnpaid;
  final int totalPaid;
  final double lunasPercentage;

  const PaymentRecapModel({
    required this.totalPendapatan,
    required this.totalPesananCount,
    required this.totalUnpaid,
    required this.totalPaid,
    required this.lunasPercentage,
  });

  factory PaymentRecapModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return PaymentRecapModel(
      totalPendapatan: data['total_pendapatan'] ?? 0,
      totalPesananCount: data['total_pesanan_count'] ?? 0,
      totalUnpaid: data['total_unpaid'] ?? 0,
      totalPaid: data['total_paid'] ?? 0,
      lunasPercentage: (data['lunas_percentage'] as num? ?? 0).toDouble(),
    );
  }
}

class DashboardActivityItemModel {
  final String title;
  final String description;
  final String date;

  const DashboardActivityItemModel({
    required this.title,
    required this.description,
    required this.date,
  });

  factory DashboardActivityItemModel.fromJson(Map<String, dynamic> json) =>
      DashboardActivityItemModel(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        date: json['date'] ?? '',
      );
}

class DashboardMetricsModel {
  final int totalPesananCount;
  final int dikirimCount;
  final int pesananSelesaiCount;
  final int belumBayarAmount;
  final int belumBayarCount;
  final int pengirimanBerlangsungCount;
  final int pengirimanSelesaiCount;
  final int pesananDiprosesCount;
  final List<DashboardActivityItemModel> aktivitasTerakhir;

  const DashboardMetricsModel({
    required this.totalPesananCount,
    required this.dikirimCount,
    required this.pesananSelesaiCount,
    required this.belumBayarAmount,
    required this.belumBayarCount,
    required this.pengirimanBerlangsungCount,
    required this.pengirimanSelesaiCount,
    required this.pesananDiprosesCount,
    required this.aktivitasTerakhir,
  });

  factory DashboardMetricsModel.fromJson(Map<String, dynamic> json) =>
      DashboardMetricsModel(
        totalPesananCount: json['total_pesanan_count'] ?? 0,
        dikirimCount: json['dikirim_count'] ?? 0,
        pesananSelesaiCount: json['pesanan_selesai_count'] ?? 0,
        belumBayarAmount: json['belum_bayar_amount'] ?? 0,
        belumBayarCount: json['belum_bayar_count'] ?? 0,
        pengirimanBerlangsungCount: json['pengiriman_berlangsung_count'] ?? 0,
        pengirimanSelesaiCount: json['pengiriman_selesai_count'] ?? 0,
        pesananDiprosesCount: json['pesanan_diproses_count'] ?? 0,
        aktivitasTerakhir: json['aktivitas_terakhir'] != null
            ? (json['aktivitas_terakhir'] as List)
                  .map((e) => DashboardActivityItemModel.fromJson(e))
                  .toList()
            : [],
      );
}

// Wrapper Response
class DashboardMetricsResponseModel {
  final bool success;
  final String message;
  final DashboardMetricsModel? data;

  const DashboardMetricsResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory DashboardMetricsResponseModel.fromJson(Map<String, dynamic> json) =>
      DashboardMetricsResponseModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null
            ? DashboardMetricsModel.fromJson(json['data'])
            : null,
      );
}

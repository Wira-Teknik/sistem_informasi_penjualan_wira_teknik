class ActivityModel {
  final String title;
  final String description;
  final String date;

  const ActivityModel({
    required this.title,
    required this.description,
    required this.date,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    date: json['date'] ?? '',
  );
}

class DashboardModel {
  // Admin & Owner
  final int totalPesananCount;
  final int dikirimCount;
  final int pesananSelesaiCount;
  final int belumBayarAmount;
  final int belumBayarCount;

  // Owner only
  final int pengirimanBerlangsungCount;
  final int pengirimanSelesaiCount;
  final int pesananDiprosesCount;

  final List<ActivityModel> aktivitasTerakhir;

  const DashboardModel({
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

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return DashboardModel(
      totalPesananCount: data['total_pesanan_count'] ?? 0,
      dikirimCount: data['dikirim_count'] ?? 0,
      pesananSelesaiCount: data['pesanan_selesai_count'] ?? 0,
      belumBayarAmount: data['belum_bayar_amount'] ?? 0,
      belumBayarCount: data['belum_bayar_count'] ?? 0,
      pengirimanBerlangsungCount: data['pengiriman_berlangsung_count'] ?? 0,
      pengirimanSelesaiCount: data['pengiriman_selesai_count'] ?? 0,
      pesananDiprosesCount: data['pesanan_diproses_count'] ?? 0,
      aktivitasTerakhir: (data['aktivitas_terakhir'] as List? ?? [])
          .map((e) => ActivityModel.fromJson(e))
          .toList(),
    );
  }
}

class PaginationModel {
  final int page;
  final int limit;
  final int totalRows;
  final int totalPages;

  const PaginationModel({
    required this.page,
    required this.limit,
    required this.totalRows,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      totalRows: json['total_rows'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}

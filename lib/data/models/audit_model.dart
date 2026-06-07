class AuditModel {
  final String id;
  final String adminName;
  final String action;
  final String actionRaw;
  final String date;
  final String description;

  const AuditModel({
    required this.id,
    required this.adminName,
    required this.action,
    required this.actionRaw,
    required this.date,
    required this.description,
  });

  factory AuditModel.fromJson(Map<String, dynamic> json) => AuditModel(
    id: json['id'] ?? '',
    adminName: json['admin_name'] ?? '',
    action: json['action'] ?? '',
    actionRaw: json['action_raw'] ?? '',
    date: json['date'] ?? '',
    description: json['description'] ?? '',
  );
}

class AuditResponseModel {
  final bool success;
  final String message;
  final List<AuditModel> data;

  const AuditResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AuditResponseModel.fromJson(Map<String, dynamic> json) =>
      AuditResponseModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: (json['data'] as List? ?? [])
            .map((e) => AuditModel.fromJson(e))
            .toList(),
      );
}

class CustomerModel {
  final String id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomerModel({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAddress,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: json['id'],
    customerName: json['customer_name'],
    customerEmail: json['customer_email'],
    customerPhone: json['customer_phone'],
    customerAddress: json['customer_address'],
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer_name': customerName,
    'customer_email': customerEmail,
    'customer_phone': customerPhone,
    'customer_address': customerAddress,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

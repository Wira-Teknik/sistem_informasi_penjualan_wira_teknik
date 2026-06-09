class EmailSenderResponseModel {
  final String message;
  final bool success;

  EmailSenderResponseModel({required this.message, required this.success});

  factory EmailSenderResponseModel.fromJson(Map<String, dynamic> json) =>
      EmailSenderResponseModel(
        message: json['message'],
        success: json['success'],
      );

  Map<String, dynamic> toJson() => {'message': message, 'success': success};
}

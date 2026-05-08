class ResetPasswordResponseModel {
  final String message;
  final bool success;

  ResetPasswordResponseModel({required this.message, required this.success});

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) =>
      ResetPasswordResponseModel(
        message: json['message'],
        success: json['success'],
      );

  Map<String, dynamic> toJson() => {'message': message, 'success': success};
}

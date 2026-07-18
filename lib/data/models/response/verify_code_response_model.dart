class VerifyCodeResponseModel {
  final String token;
  final String message;
  final bool success;

  VerifyCodeResponseModel({
    required this.token,
    required this.message,
    required this.success,
  });

  factory VerifyCodeResponseModel.fromJson(Map<String, dynamic> json) =>
      VerifyCodeResponseModel(
        token: json['data']['token'],
        message: json['message'],
        success: json['success'],
      );

  Map<String, dynamic> toJson() => {
    'data': {'token': token},
    'message': message,
    'success': success,
  };
}

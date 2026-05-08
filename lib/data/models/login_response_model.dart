import 'package:sistem_informasi_penjualan_wira_teknik/data/models/user_model.dart';

class LoginResponseModel {
  final bool success;
  final String message;
  final String token;
  final UserModel user;

  const LoginResponseModel({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        success: json['success'],
        message: json['message'],
        token: json['data']['token'],
        user: UserModel.fromJson(json['data']['user']),
      );

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': {'token': token, 'user': user.toJson()},
  };
}

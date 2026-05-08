import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/data/models/login_response_model.dart';

class Jwt {
  static Map<String, dynamic> decodeToken(String token) {
    final LoginResponseModel data = jsonDecode(token);
    final jwt = JWT.decode(data.token);
    return jwt.payload;
  }
}

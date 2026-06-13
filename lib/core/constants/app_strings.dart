import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppStrings {
  AppStrings._();

  static const appName = 'SIP Wira Teknik';

  static String get baseUrl => dotenv.env['API_BASE_URL']!;
  static String get imageUrl => dotenv.env['IMAGE_URL']!;

  static const loginEndpoint = '/auth/login';
  static const forgotPasswordRequestEndpoint = '/auth/forgot-password/request';
  static const verifyCodeEndpoint = '/auth/forgot-password/verify';
  static const forgotPasswordResetEndpoint = '/auth/forgot-password/reset';
  static const customersEndpoint = '/customers';
  static const ordersEndpoint = '/orders';
  static const shipmentsEndpoint = '/shipments';
  static const attachmentsEndpoint = '/attachments';
  static const dashboardEndpoint = '/dashboard';

  static const tokenKey = 'token';
  static const userIdKey = 'user_id';
  static const userNameKey = 'user_name';
  static const userEmailKey = 'user_email';
  static const userRoleKey = 'user_role';
}

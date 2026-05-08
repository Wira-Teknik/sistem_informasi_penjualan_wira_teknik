class AppStrings {
  AppStrings._();

  static const appName = 'Wira Teknik';
  static const baseUrl = 'https://wirateknik.backendify.my.id/api/v1';

  // endpoint
  static const loginEndpoint = '/auth/login';
  static const forgotPasswordRequestEndpoint = '/auth/forgot-password/request';
  static const verifyCodeEndpoint = '/auth/forgot-password/verify';
  static const forgotPasswordResetEndpoint = '/auth/forgot-password/reset';
  static const customersEndpoint = '/customers';

  // Secure storage keys
  static const tokenKey = 'token';
  static const userIdKey = 'user_id';
  static const userNameKey = 'user_name';
  static const userEmailKey = 'user_email';
  static const userRoleKey = 'user_role';
}

import 'package:flutter/material.dart';

// GlobalKey yang bisa diakses dari mana saja termasuk interceptor
class AppNavigator {
  AppNavigator._();

  static final navigatorKey = GlobalKey<NavigatorState>();

  static void goToLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
      arguments: {'expired': true},
    );
  }
}

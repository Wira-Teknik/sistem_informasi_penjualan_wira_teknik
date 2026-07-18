import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/constants/color_constant.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/core/utils/app_navigator.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/auth/email_sender_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/auth/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/auth/reset_password_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/auth/verify_code_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/screens/splash/splash_screen.dart';
import 'package:sistem_informasi_penjualan_wira_teknik/views/widgets/bottom_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: backgroundColor),
      debugShowCheckedModeBanner: false,
      title: 'SIP Wira Teknik',
      navigatorKey: AppNavigator.navigatorKey,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/bottom_navigation': (_) => const BottomNavigation(),
        '/email_sender': (_) => const EmailSenderScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/verify_code':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => VerifyCodeScreen(email: args['email']),
            );

          case '/reset_password':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(token: args['token']),
            );

          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}

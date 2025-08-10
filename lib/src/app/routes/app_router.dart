import 'package:flutter/material.dart';
import '../../features/1_auth/login/view/login_page.dart';
import '../../features/1_auth/register/view/register_page.dart';
import '../../features/1_auth/forgot_password/view/forgot_password_page.dart';
import '../../features/1_auth/verify_otp/view/verify_otp_page.dart';
import '../../features/2_home/view/home_page.dart';
import '../../features/0_splash/view/splash_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case '/verify-otp':
        return MaterialPageRoute(builder: (_) => const OtpVerificationPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Halaman tidak ditemukan')),
          ),
        );
    }
  }
}
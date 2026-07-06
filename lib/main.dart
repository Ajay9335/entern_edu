import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const InternEduApp());
}

class InternEduApp extends StatelessWidget {
  const InternEduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intern Edu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (ctx) => const SplashScreen(),
        AppRoutes.login: (ctx) => const LoginScreen(),
        AppRoutes.signup: (ctx) => const SignupScreen(),
        AppRoutes.registration: (ctx) => const RegistrationScreen(),
        AppRoutes.forgotPassword: (ctx) => const ForgotPasswordScreen(),
        AppRoutes.dashboard: (ctx) => const DashboardScreen(),
      },
    );
  }
}

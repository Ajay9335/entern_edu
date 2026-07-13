import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F80ED),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 48,
                    height: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Intern Edu',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2A44),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create a new account or log in to continue your internship journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80ED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.registration);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2F80ED),
                      side: const BorderSide(color: Color(0xFF2F80ED)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Create New Account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

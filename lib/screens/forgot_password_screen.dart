import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/placeholder_scaffold.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(
      title: 'Forgot Password',
      description: 'Placeholder for password recovery flow.',
      actions: [
        ElevatedButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.login),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}

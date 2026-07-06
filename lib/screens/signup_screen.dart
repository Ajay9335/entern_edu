import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/placeholder_scaffold.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(
      title: 'Sign Up',
      description: 'Create a new account using this placeholder screen.',
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.registration),
          child: const Text('Continue to Registration'),
        ),
      ],
    );
  }
}

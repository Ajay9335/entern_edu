import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/placeholder_scaffold.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(
      title: 'Registration',
      description: 'Finish registration and return to login.',
      actions: [
        ElevatedButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.login),
          child: const Text('Register'),
        ),
      ],
    );
  }
}

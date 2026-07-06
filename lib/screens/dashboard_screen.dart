import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/placeholder_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(
      title: 'Dashboard',
      description: 'This placeholder dashboard shows the logged-in state.',
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          ),
          child: const Text('Logout'),
        ),
      ],
    );
  }
}

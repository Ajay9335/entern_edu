import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _submitted = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final error = await AuthService.instance.sendPasswordResetEmail(
      email: _emailController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        foregroundColor: AppTheme.black,
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _submitted ? _buildConfirmation() : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_reset, size: 64, color: AppTheme.primaryOrange),
          const SizedBox(height: 20),
          const Text(
            'Reset your password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Enter your registered email and we'll send you a reset link",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.textGray),
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _onSubmit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Send Reset Link'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 72,
          color: AppTheme.primaryOrange,
        ),
        const SizedBox(height: 20),
        const Text(
          'Check your email',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A password reset link has been sent to ${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppTheme.textGray),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/auth_providers.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  bool _isBusy = false;

  Future<void> _resendEmail() async {
    setState(() => _isBusy = true);
    try {
      await ref.read(authRepositoryProvider).resendVerificationEmail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent.')),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _checkVerification() async {
    setState(() => _isBusy = true);
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.reloadUser();
      ref.invalidate(authStateChangesProvider);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 64),
              const SizedBox(height: 20),
              Text(
                'Check your inbox',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'We sent a verification link to your ALU email. Verify it before continuing.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isBusy ? null : _checkVerification,
                child: const Text('I have verified my email'),
              ),
              TextButton(
                onPressed: _isBusy ? null : _resendEmail,
                child: const Text('Resend verification email'),
              ),
              TextButton(
                onPressed: _isBusy
                    ? null
                    : () => ref.read(authRepositoryProvider).signOut(),
                child: const Text('Use a different account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/home/presentation/home_page.dart';
import '../application/auth_providers.dart';
import 'auth_page.dart';
import 'verify_email_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Unable to load authentication: $error'),
        ),
      ),
      data: (user) {
        if (user == null) {
          return const AuthPage();
        }
        if (!user.emailVerified) {
          return const VerifyEmailPage();
        }
        return const HomePage();
      },
    );
  }
}

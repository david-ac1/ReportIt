import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/home/presentation/home_page.dart';
import '../application/auth_providers.dart';
import '../application/role_providers.dart';
import 'auth_page.dart';
import 'verify_email_page.dart';
import '../../staff/presentation/staff_home_page.dart';

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
        return const _RoleGate();
      },
    );
  }
}

class _RoleGate extends ConsumerWidget {
  const _RoleGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(isStaffProvider);
    return role.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => const HomePage(),
      data: (isStaff) => isStaff ? const StaffHomePage() : const HomePage(),
    );
  }
}

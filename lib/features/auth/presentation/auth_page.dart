import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/auth_providers.dart';

bool isAllowedAluEmail(String email) {
  return RegExp(
    r'^[^@\s]+@alustudent\.com$',
    caseSensitive: false,
  ).hasMatch(email.trim());
}

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  _AuthMode _mode = _AuthMode.studentSignIn;
  bool _isBusy = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isBusy = true);
    try {
      final repository = ref.read(authRepositoryProvider);
      if (_mode == _AuthMode.studentRegistration) {
        await repository.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await repository.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageFor(error))));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  String _messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'The email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Use a password with at least six characters.';
      case 'network-request-failed':
        return 'Network unavailable. Check your connection and try again.';
      case 'internal-error':
      case 'configuration-not-found':
        return 'Firebase Authentication is not configured. Enable Email/Password '
            'sign-in in the Firebase Console.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudentRegistration = _mode == _AuthMode.studentRegistration;
    final isStaffSignIn = _mode == _AuthMode.staffSignIn;
    final title = isStudentRegistration
        ? 'Student sign up'
        : isStaffSignIn
        ? 'Staff sign in'
        : 'Student sign in';
    final action = isStudentRegistration ? 'Create student account' : 'Sign in';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'ReportIt',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton<_AuthMode>(
                    segments: const [
                      ButtonSegment(
                        value: _AuthMode.studentSignIn,
                        label: Text('Student'),
                        icon: Icon(Icons.school_outlined),
                      ),
                      ButtonSegment(
                        value: _AuthMode.staffSignIn,
                        label: Text('Staff'),
                        icon: Icon(Icons.badge_outlined),
                      ),
                    ],
                    selected: {
                      isStaffSignIn
                          ? _AuthMode.staffSignIn
                          : _AuthMode.studentSignIn,
                    },
                    onSelectionChanged: _isBusy
                        ? null
                        : (selection) {
                            setState(() {
                              _mode = selection.first;
                            });
                          },
                  ),
                  if (isStaffSignIn)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Staff accounts are created by an administrator. '
                        'Use your authorized staff email.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter your email address.';
                      }
                      if (!isStaffSignIn && !isAllowedAluEmail(value)) {
                        return 'Use your @alustudent.com email.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your password.';
                      }
                      if (isStudentRegistration && value.length < 6) {
                        return 'Use at least six characters.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isBusy ? null : _submit,
                    child: _isBusy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(action),
                  ),
                  const SizedBox(height: 12),
                  if (!isStaffSignIn)
                    TextButton(
                      onPressed: _isBusy
                          ? null
                          : () => setState(
                              () => _mode = isStudentRegistration
                                  ? _AuthMode.studentSignIn
                                  : _AuthMode.studentRegistration,
                            ),
                      child: Text(
                        isStudentRegistration
                            ? 'Already a student? Sign in'
                            : 'New student? Create an account',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _AuthMode { studentSignIn, studentRegistration, staffSignIn }

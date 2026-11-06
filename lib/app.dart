import 'package:flutter/material.dart';

import 'features/auth/presentation/auth_gate.dart';
import 'theme/app_theme.dart';

class ReportItApp extends StatelessWidget {
  const ReportItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReportIt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}

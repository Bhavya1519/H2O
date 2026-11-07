import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const H2OApp());
}

class H2OApp extends StatelessWidget {
  const H2OApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'H2O',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}

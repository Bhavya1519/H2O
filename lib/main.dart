import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return const ProviderScope(
      child: _H2ORouterApp(),
    );
  }
}

class _H2ORouterApp extends StatelessWidget {
  const _H2ORouterApp();

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

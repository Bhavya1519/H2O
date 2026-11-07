import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/ble/presentation/ble_scan_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../theme/app_theme.dart';

/// Navigation routes enum for type-safe route paths
enum AppRoute {
  splash('/'),
  login('/login'),
  bleScan('/ble-scan'),
  dashboard('/dashboard');

  final String path;
  const AppRoute(this.path);
}

/// Helper to generate smooth slide and fade page transitions between screens
CustomTransitionPage<T> _buildSlideFadeTransition<T>({
  required Widget child,
  required LocalKey key,
  Offset beginOffset = const Offset(0.08, 0.0),
  Duration duration = const Duration(milliseconds: 400),
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.easeInCubic,
      );

      final slideAnimation = Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(curvedAnimation);

      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(curvedAnimation);

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}

/// Central GoRouter configuration for AuraDrop
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoute.splash.path,
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    // 1. Splash Screen
    GoRoute(
      path: AppRoute.splash.path,
      name: 'splash',
      pageBuilder: (context, state) => _buildSlideFadeTransition(
        key: state.pageKey,
        child: const SplashScreen(),
        beginOffset: Offset.zero,
        duration: const Duration(milliseconds: 300),
      ),
    ),

    // 2. Login Screen
    GoRoute(
      path: AppRoute.login.path,
      name: 'login',
      pageBuilder: (context, state) => _buildSlideFadeTransition(
        key: state.pageKey,
        child: const LoginScreen(),
        beginOffset: const Offset(0.0, 0.06), // Subtle slide up
      ),
    ),

    // 3. BLE Scan Screen
    GoRoute(
      path: AppRoute.bleScan.path,
      name: 'ble-scan',
      pageBuilder: (context, state) => _buildSlideFadeTransition(
        key: state.pageKey,
        child: const BleScanScreen(),
        beginOffset: const Offset(0.12, 0.0), // Smooth horizontal slide
      ),
    ),

    // 4. Main Dashboard Screen (Slide & Fade from BLE connection flow)
    GoRoute(
      path: AppRoute.dashboard.path,
      name: 'dashboard',
      pageBuilder: (context, state) => _buildSlideFadeTransition(
        key: state.pageKey,
        child: const DashboardScreen(),
        beginOffset: const Offset(0.0, 0.08), // Upward emergence for dashboard
        duration: const Duration(milliseconds: 450),
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF0F172A),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.roseError, size: 48),
          const SizedBox(height: 16),
          Text(
            'Route not found: ${state.uri}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoute.splash.path),
            child: const Text('Return Home'),
          ),
        ],
      ),
    ),
  ),
);

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

/// Splash Screen featuring a pulsating liquid aura and smooth route transition.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Auto navigate after 3.2 seconds
    _navigationTimer = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient background glow circles
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyanAccent.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.azureAccent.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Central content
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Animated Glowing Water Drop Aura
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.liquidGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cyanAccent
                                      .withValues(alpha: 0.4),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: AppColors.azureAccent
                                      .withValues(alpha: 0.25),
                                  blurRadius: 60,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.water_drop_rounded,
                                size: 76,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 36),

                    // App Title
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.liquidGradient.createShader(bounds),
                      child: const Text(
                        'H2O',
                        style: TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle / Tagline
                    Text(
                      'SMART IoT HYDRATION ECOSYSTEM',
                      style: AppTypography.metricCaption.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 2.5,
                      ),
                    ),

                    const Spacer(),

                    // Skip button to fast-forward
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Get Started',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.cyanAccent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: AppColors.cyanAccent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/liquid_wave_gauge.dart';

/// Flagship Dashboard Screen for AuraDrop IoT Hydration Tracker.
/// Features interactive hydration logging, live bottle metrics, and glassmorphic stats.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _currentIntakeMl = 2150;
  final int _targetGoalMl = 2800;
  final double _waterTempCelsius = 16.5;
  int _streakDays = 14;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _addWater(int amount) {
    setState(() {
      _currentIntakeMl = (_currentIntakeMl + amount).clamp(0, 5000);
      if (_currentIntakeMl >= _targetGoalMl && _streakDays == 14) {
        _streakDays = 15;
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.water_drop, color: AppColors.cyanAccent, size: 20),
            const SizedBox(width: 10),
            Text(
              '+$amount ml recorded from H2O Bottle',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIntakeMl / _targetGoalMl).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient lighting behind the hydration circle
          Positioned(
            top: 120,
            left: MediaQuery.of(context).size.width / 2 - 160,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyanAccent.withValues(alpha: 0.16),
                    AppColors.azureAccent.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Custom App Bar with IoT Connection Badge
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Connected Bottle Status Chip
                        GestureDetector(
                          onTap: () => context.go('/ble-scan'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.glassBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.emeraldAccent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.emeraldAccent,
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'H2O Bottle Pro',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.battery_charging_full_rounded,
                                  size: 14,
                                  color: AppColors.emeraldAccent,
                                ),
                                Text(
                                  ' 92%',
                                  style: AppTypography.labelSmall.copyWith(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Actions
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.bluetooth_rounded,
                                color: AppColors.cyanAccent,
                              ),
                              onPressed: () => context.go('/ble-scan'),
                              tooltip: 'BLE Devices',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () => context.go('/login'),
                              tooltip: 'Sign Out',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Hydration Circle Gauge Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: GlassmorphicCard(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            'CURRENT HYDRATION',
                            style: AppTypography.metricCaption.copyWith(
                              color: AppColors.textCyanHighlight,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Interactive Animated Liquid Wave Gauge
                          LiquidWaveGauge(
                            progress: progress,
                            currentIntakeMl: _currentIntakeMl,
                            targetGoalMl: _targetGoalMl,
                            waterTempCelsius: _waterTempCelsius,
                            size: 220,
                          ),

                          const SizedBox(height: 28),

                          // Quick Intake Log Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildQuickAddButton(150, Icons.local_cafe_rounded),
                              _buildQuickAddButton(250, Icons.water_drop_rounded),
                              _buildQuickAddButton(500, Icons.local_drink_rounded),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Metric Highlights Row (Streak, Remaining, IoT Battery)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Streak Card
                        Expanded(
                          child: GlassmorphicCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.amberWarning.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.local_fire_department_rounded,
                                    color: AppColors.amberWarning,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '$_streakDays DAYS',
                                  style: AppTypography.titleLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Daily Streak',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Goal Remaining Card
                        Expanded(
                          child: GlassmorphicCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.emeraldAccent.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.track_changes_rounded,
                                    color: AppColors.emeraldAccent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${(_targetGoalMl - _currentIntakeMl).clamp(0, _targetGoalMl)} ml',
                                  style: AppTypography.titleLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'To Reach Goal',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(int amount, IconData icon) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _addWater(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.cyanAccent),
            const SizedBox(width: 6),
            Text(
              '+$amount ml',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

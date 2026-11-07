import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../data/hydration_service.dart';
import 'widgets/bottle_settings_sheet.dart';
import 'widgets/hourly_intake_chart.dart';
import 'widgets/liquid_bottle_widget.dart';
import 'widgets/liquid_wave_gauge.dart';

/// Flagship Dashboard Screen for H2O IoT Hydration Tracker.
/// Features interactive hydration logging, live bottle metrics, hourly rhythm charts,
/// and hardware diagnostics.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HydrationService _hydrationService = HydrationService();
  bool _showBottleView = false;

  void _addWater(int amount) {
    _hydrationService.logIntake(amount);

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
    return ListenableBuilder(
      listenable: _hydrationService,
      builder: (context, _) {
        final progress = _hydrationService.progress;

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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Connected Bottle Status Chip (taps to open diagnostics)
                            GestureDetector(
                              onTap: () => BottleSettingsSheet.show(
                                context,
                                _hydrationService,
                              ),
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
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _hydrationService.isConnected
                                            ? AppColors.emeraldAccent
                                            : AppColors.roseError,
                                        boxShadow: [
                                          BoxShadow(
                                            color: _hydrationService.isConnected
                                                ? AppColors.emeraldAccent
                                                : AppColors.roseError,
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _hydrationService.connectedDeviceName,
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
                                      ' ${_hydrationService.batteryPercent}%',
                                      style: AppTypography.labelSmall.copyWith(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Actions: Settings & Sign Out
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.tune_rounded,
                                    color: AppColors.cyanAccent,
                                  ),
                                  onPressed: () => BottleSettingsSheet.show(
                                    context,
                                    _hydrationService,
                                  ),
                                  tooltip: 'Bottle Settings',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.bluetooth_rounded,
                                    color: AppColors.skyHighlight,
                                  ),
                                  onPressed: () => context.go('/ble-scan'),
                                  tooltip: 'BLE Scanner',
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

                    // Sterilization Active Banner (if cleaning)
                    if (_hydrationService.isSterilizing)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9333EA), Color(0xFF6B21A8)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9333EA).withValues(alpha: 0.35),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.cleaning_services_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'UV-C Purification in progress (${_hydrationService.sterilizationSecondsRemaining}s left)',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Main Hydration Circle Gauge Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: GlassmorphicCard(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 20,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _showBottleView ? 'SMART BOTTLE LEVEL' : 'CURRENT HYDRATION',
                                    style: AppTypography.metricCaption.copyWith(
                                      color: AppColors.textCyanHighlight,
                                    ),
                                  ),
                                  // View Switcher Pill
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.surface.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppColors.glassBorder),
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => setState(() => _showBottleView = false),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: !_showBottleView
                                                  ? AppColors.cyanAccent.withValues(alpha: 0.25)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.donut_large_rounded,
                                                  size: 13,
                                                  color: !_showBottleView
                                                      ? AppColors.cyanAccent
                                                      : AppColors.textMuted,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Gauge',
                                                  style: AppTypography.labelSmall.copyWith(
                                                    fontSize: 11,
                                                    color: !_showBottleView
                                                        ? Colors.white
                                                        : AppColors.textMuted,
                                                    fontWeight: !_showBottleView
                                                        ? FontWeight.w700
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => setState(() => _showBottleView = true),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _showBottleView
                                                  ? AppColors.cyanAccent.withValues(alpha: 0.25)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.local_drink_rounded,
                                                  size: 13,
                                                  color: _showBottleView
                                                      ? AppColors.cyanAccent
                                                      : AppColors.textMuted,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Bottle',
                                                  style: AppTypography.labelSmall.copyWith(
                                                    fontSize: 11,
                                                    color: _showBottleView
                                                        ? Colors.white
                                                        : AppColors.textMuted,
                                                    fontWeight: _showBottleView
                                                        ? FontWeight.w700
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Animated Switcher between Circular Gauge and Bottle Widget
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 350),
                                crossFadeState: _showBottleView
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                firstChild: Center(
                                  child: LiquidWaveGauge(
                                    progress: progress,
                                    currentIntakeMl: _hydrationService.currentIntakeMl,
                                    targetGoalMl: _hydrationService.targetGoalMl,
                                    waterTempCelsius: _hydrationService.waterTempCelsius,
                                    size: 220,
                                  ),
                                ),
                                secondChild: Center(
                                  child: LiquidBottleWidget(
                                    capacityMl: _hydrationService.bottleCapacityMl,
                                    currentVolumeMl: _hydrationService.bottleCurrentWaterMl,
                                    height: 310,
                                    width: 155,
                                    enableMockSipOnClick: true,
                                    onVolumeChanged: (newVolume) {
                                      _hydrationService.onBottleVolumeUpdated(newVolume);
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

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

                    const SliverToBoxAdapter(child: SizedBox(height: 12)),

                    // Metric Highlights Row (Streak & Remaining)
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
                                      '${_hydrationService.streakDays} DAYS',
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
                                      '${_hydrationService.remainingMl} ml',
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

                    const SliverToBoxAdapter(child: SizedBox(height: 14)),

                    // Hourly Rhythm Chart
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: HourlyIntakeChart(
                          history: _hydrationService.hourlyHistory,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

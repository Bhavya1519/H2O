import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../water_tracker/presentation/water_provider.dart';
import '../data/hydration_service.dart';
import 'widgets/bottle_settings_sheet.dart';
import 'widgets/hourly_intake_chart.dart';
import 'widgets/liquid_bottle_widget.dart';
import 'widgets/liquid_wave_gauge.dart';

/// Flagship Dashboard Screen for H2O IoT Hydration Tracker.
///
/// Features:
/// 1. Top status bar showing connected bottle connection indicator, device name, and battery level.
/// 2. Centerpiece [LiquidBottleWidget] driven reactively by [waterBottleProvider].
/// 3. Sleek horizontal metric card under the bottle displaying Daily Target Progress & Last Sip Timestamp.
/// 4. Micro-interactions: Celebratory confetti and particle pop whenever a new sip is detected.
/// 5. Quick intake logging buttons (+150 mL, +250 mL, +500 mL) and hourly rhythm analytics.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  final HydrationService _hydrationService = HydrationService();
  bool _showBottleView = true;

  // Confetti / Particle Pop Animation Controller
  late AnimationController _confettiController;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// Generates a randomized cluster of vibrant celebratory particles
  void _generateConfettiBurst() {
    _particles.clear();
    final colors = [
      AppColors.cyanAccent,
      AppColors.azureAccent,
      AppColors.emeraldAccent,
      AppColors.skyHighlight,
      const Color(0xFFFACC15), // Celebratory Gold
      Colors.white,
    ];

    for (int i = 0; i < 42; i++) {
      _particles.add(
        _ConfettiParticle(
          angle: _random.nextDouble() * 2 * math.pi,
          speed: 80.0 + _random.nextDouble() * 180.0,
          size: 4.5 + _random.nextDouble() * 5.5,
          color: colors[_random.nextInt(colors.length)],
          rotationSpeed: (_random.nextDouble() - 0.5) * 8.0,
          isCircle: _random.nextBool(),
        ),
      );
    }
  }

  /// Triggers celebratory confetti burst and feedback snackbar upon sip detection
  void _triggerSipCelebration(int sipAmount) {
    _generateConfettiBurst();
    _confettiController.forward(from: 0.0);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(milliseconds: 2000),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.emeraldAccent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.emeraldAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sip Detected: +$sipAmount mL',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Hydration progress updated automatically!',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addWater(int amount) {
    ref.read(waterBottleProvider.notifier).recordManualSip(amount);
    _hydrationService.logIntake(amount);
  }

  @override
  Widget build(BuildContext context) {
    // Reactively watch WaterBottleState from Riverpod
    final bottleAsync = ref.watch(waterBottleProvider);
    final bottleState = bottleAsync.value ?? const WaterBottleState();

    // Micro-interaction listener: Trigger confetti celebration when a new sip is detected
    ref.listen<AsyncValue<WaterBottleState>>(waterBottleProvider, (previous, next) {
      final prevConsumed = previous?.value?.todayTotalConsumedMl ?? 0;
      final nextConsumed = next.value?.todayTotalConsumedMl ?? 0;
      final lastSip = next.value?.lastSipAmount ?? 0;

      if (nextConsumed > prevConsumed && lastSip > 0) {
        _triggerSipCelebration(lastSip);
      }
    });

    return ListenableBuilder(
      listenable: _hydrationService,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Ambient radial glow behind bottle
              Positioned(
                top: 140,
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
                    // === 1. Top Status Bar with Connection Indicator & Battery ===
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: _buildTopStatusBar(bottleState),
                      ),
                    ),

                    // Sterilization Active Banner (if purification running)
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

                    // === 2. Centerpiece Card: LiquidBottleWidget driven by waterProvider ===
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: GlassmorphicCard(
                          padding: const EdgeInsets.symmetric(
                            vertical: 22,
                            horizontal: 20,
                          ),
                          child: Column(
                            children: [
                              // View switcher (Bottle vs Gauge)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _showBottleView ? 'SMART BOTTLE LEVEL' : 'CIRCULAR GAUGE',
                                    style: AppTypography.metricCaption.copyWith(
                                      color: AppColors.textCyanHighlight,
                                    ),
                                  ),
                                  _buildViewSwitcher(),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Interactive Centerpiece Widget
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 350),
                                crossFadeState: _showBottleView
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                firstChild: Center(
                                  child: LiquidWaveGauge(
                                    progress: bottleState.dailyTargetProgress,
                                    currentIntakeMl: bottleState.todayTotalConsumedMl,
                                    targetGoalMl: bottleState.dailyTargetMl,
                                    waterTempCelsius: _hydrationService.waterTempCelsius,
                                    size: 220,
                                  ),
                                ),
                                secondChild: Center(
                                  child: LiquidBottleWidget(
                                    capacityMl: bottleState.totalCapacityMl,
                                    currentVolumeMl: bottleState.currentVolumeMl,
                                    height: 330,
                                    width: 165,
                                    enableMockSipOnClick: true,
                                    onVolumeChanged: (newVolume) {
                                      // Simulated sip from tapping bottle in mock mode
                                      _addWater(50);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // === 3. Sleek Horizontal Metric Card Under the Bottle ===
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        child: _buildHorizontalMetricCard(bottleState),
                      ),
                    ),

                    // Quick Intake Log Buttons (+150 mL, +250 mL, +500 mL)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickAddButton(150, Icons.local_cafe_rounded, 'Coffee/Tea'),
                            _buildQuickAddButton(250, Icons.water_drop_rounded, 'Glass'),
                            _buildQuickAddButton(500, Icons.local_drink_rounded, 'Bottle'),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 10)),

                    // Metric Highlights Row (Streak & Remaining Target)
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

                            // Remaining Goal Card
                            Expanded(
                              child: GlassmorphicCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.cyanAccent.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.track_changes_rounded,
                                        color: AppColors.cyanAccent,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '${bottleState.remainingGoalMl} mL',
                                      style: AppTypography.titleLarge.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.skyHighlight,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Left to Drink',
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

                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // Hourly Hydration Intake Analytics Chart
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: HourlyIntakeChart(
                          history: _hydrationService.hourlyHistory,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
              ),

              // === 4. Micro-interaction: Confetti / Particle Pop Celebration Overlay ===
              AnimatedBuilder(
                animation: _confettiController,
                builder: (context, _) {
                  if (!_confettiController.isAnimating) {
                    return const SizedBox.shrink();
                  }
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _ConfettiPainter(
                          particles: _particles,
                          progress: _confettiController.value,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // === Top Status Bar Component ===
  Widget _buildTopStatusBar(WaterBottleState bottleState) {
    final isConnected = bottleState.connectionStatus.isConnected;
    final isScanning = bottleState.connectionStatus.isScanning;

    final statusColor = isConnected
        ? AppColors.emeraldAccent
        : (isScanning ? AppColors.amberWarning : AppColors.roseError);

    final statusText = isConnected
        ? _hydrationService.connectedDeviceName
        : (isScanning ? 'Scanning...' : 'Disconnected');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Connected Bottle Status Chip (taps to open diagnostics)
        GestureDetector(
          onTap: () => BottleSettingsSheet.show(context, _hydrationService),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isConnected
                    ? AppColors.emeraldAccent.withValues(alpha: 0.35)
                    : AppColors.glassBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Status Dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor,
                        blurRadius: 7,
                        spreadRadius: 1.5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                // Battery Indicator
                Icon(
                  bottleState.batteryPercent > 20
                      ? Icons.battery_charging_full_rounded
                      : Icons.battery_alert_rounded,
                  size: 15,
                  color: bottleState.batteryPercent > 20
                      ? AppColors.emeraldAccent
                      : AppColors.roseError,
                ),
                Text(
                  ' ${bottleState.batteryPercent}%',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Actions: Settings, BLE Scanner, Sign Out
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.tune_rounded, color: AppColors.cyanAccent),
              onPressed: () => BottleSettingsSheet.show(context, _hydrationService),
              tooltip: 'Bottle Settings',
            ),
            IconButton(
              icon: const Icon(Icons.bluetooth_rounded, color: AppColors.skyHighlight),
              onPressed: () => context.go('/ble-scan'),
              tooltip: 'BLE Scanner',
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted),
              onPressed: () => context.go('/login'),
              tooltip: 'Sign Out',
            ),
          ],
        ),
      ],
    );
  }

  // === Sleek Horizontal Metric Card Under the Bottle ===
  Widget _buildHorizontalMetricCard(WaterBottleState bottleState) {
    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Daily Target Progress
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.cyanAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        color: AppColors.cyanAccent,
                        size: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DAILY TARGET PROGRESS',
                      style: AppTypography.metricCaption.copyWith(
                        fontSize: 9.5,
                        color: AppColors.textCyanHighlight,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${bottleState.todayTotalConsumedMl}',
                      style: AppTypography.titleLarge.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      ' / ${bottleState.dailyTargetMl} mL',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Animated Gradient Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        color: const Color(0xFFE2E8F0),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0.0,
                          end: bottleState.dailyTargetProgress,
                        ),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (context, animatedProg, _) {
                          return FractionallySizedBox(
                            widthFactor: animatedProg,
                            child: Container(
                              height: 6,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.cyanAccent,
                                    AppColors.azureAccent,
                                    AppColors.emeraldAccent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(bottleState.dailyTargetProgress * 100).toInt()}% achieved (${bottleState.remainingGoalMl} mL left)',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),

          // Vertical Glass Divider
          Container(
            height: 66,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  AppColors.glassBorder,
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),

          // Right: Last Sip Timestamp
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.emeraldAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.schedule_rounded,
                        color: AppColors.emeraldAccent,
                        size: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LAST SIP',
                      style: AppTypography.metricCaption.copyWith(
                        fontSize: 9.5,
                        color: AppColors.emeraldAccent,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  bottleState.formattedLastSipTime,
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (bottleState.lastSipAmount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldAccent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.emeraldAccent.withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_drop_up_rounded,
                          color: AppColors.emeraldAccent,
                          size: 15,
                        ),
                        Text(
                          '+${bottleState.lastSipAmount} mL',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.emeraldAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'Awaiting sip...',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === View Switcher Component ===
  Widget _buildViewSwitcher() {
    return Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    color: !_showBottleView ? AppColors.cyanAccent : AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Gauge',
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 11,
                      color: !_showBottleView ? Colors.white : AppColors.textMuted,
                      fontWeight: !_showBottleView ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showBottleView = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    color: _showBottleView ? AppColors.cyanAccent : AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Bottle',
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 11,
                      color: _showBottleView ? Colors.white : AppColors.textMuted,
                      fontWeight: _showBottleView ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === Quick Intake Log Button Component ===
  Widget _buildQuickAddButton(int amount, IconData icon, String label) {
    return GestureDetector(
      onTap: () => _addWater(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 22),
            const SizedBox(height: 6),
            Text(
              '+$amount',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'mL',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === Particle Model for Confetti Burst ===
class _ConfettiParticle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double rotationSpeed;
  final bool isCircle;

  _ConfettiParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.isCircle,
  });
}

// === CustomPainter for Celebratory Particle Pop / Confetti ===
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress; // 0.0 to 1.0

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0 || particles.isEmpty) return;

    // Center burst around the middle of the bottle centerpiece
    final center = Offset(size.width / 2, size.height * 0.38);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final distance = p.speed * Curves.easeOutCubic.transform(progress);
      final gravity = 100.0 * progress * progress; // Graceful downward gravity pull

      final x = center.dx + math.cos(p.angle) * distance;
      final y = center.dy + math.sin(p.angle) * distance + gravity;

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * p.rotationSpeed);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

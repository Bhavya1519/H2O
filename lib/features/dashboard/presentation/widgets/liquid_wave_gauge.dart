import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Interactive, animated dual-sine-wave liquid container for AuraDrop hydration tracking.
class LiquidWaveGauge extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final int currentIntakeMl;
  final int targetGoalMl;
  final double waterTempCelsius;
  final double size;

  const LiquidWaveGauge({
    super.key,
    required this.progress,
    required this.currentIntakeMl,
    required this.targetGoalMl,
    required this.waterTempCelsius,
    this.size = 230,
  });

  @override
  State<LiquidWaveGauge> createState() => _LiquidWaveGaugeState();
}

class _LiquidWaveGaugeState extends State<LiquidWaveGauge>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _bubbleController;

  @override
  void initState() {
    super.initState();
    // Continuous horizontal wave translation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    // Ambient floating bubble animation
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.progress * 100).toInt();

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glowing Ambient Halo
          Container(
            width: widget.size + 24,
            height: widget.size + 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyanAccent.withValues(alpha: 0.22),
                  blurRadius: 36,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: AppColors.azureAccent.withValues(alpha: 0.15),
                  blurRadius: 48,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),

          // Main Glass Orb Housing
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.backgroundDark.withValues(alpha: 0.8),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 2.0,
              ),
            ),
            child: ClipOval(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated Wave Canvas with Smooth Height Interpolation
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: widget.progress),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedProgress, child) {
                      return AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, _) {
                          return CustomPaint(
                            size: Size(widget.size, widget.size),
                            painter: _DualWavePainter(
                              wavePhase: _waveController.value * 2 * math.pi,
                              fillProgress: animatedProgress,
                              bubbleProgress: _bubbleController.value,
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // Subtle Glass Top Reflection Arc
                  Positioned(
                    top: 8,
                    left: 28,
                    right: 28,
                    height: widget.size * 0.32,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(widget.size * 0.4, 28),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.22),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Central Foreground Typography and Metrics
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Volume and unit
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${widget.currentIntakeMl}',
                            style: AppTypography.metricValue.copyWith(
                              fontSize: widget.size * 0.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'ml',
                            style: AppTypography.metricUnit.copyWith(
                              color: AppColors.skyHighlight,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Percentage of Goal
                      Text(
                        '$percentage% of ${widget.targetGoalMl} ml',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.7),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Temperature Capsule Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDark.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.glassBorderCyan,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.thermostat_rounded,
                              size: 13,
                              color: AppColors.skyHighlight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.waterTempCelsius.toStringAsFixed(1)}°C • Refreshing',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.skyHighlight,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for dual sine-wave liquid rendering with ambient floating bubbles
class _DualWavePainter extends CustomPainter {
  final double wavePhase;
  final double fillProgress; // 0.0 to 1.0
  final double bubbleProgress;

  _DualWavePainter({
    required this.wavePhase,
    required this.fillProgress,
    required this.bubbleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fillProgress <= 0.001) return;

    final width = size.width;
    final height = size.height;

    // Calculate baseline water level (0 at bottom, 1 at top)
    final clampedFill = fillProgress.clamp(0.0, 1.0);
    final waterLevelY = height * (1.0 - clampedFill);

    // Wave parameters
    final amplitude = clampedFill >= 0.98 || clampedFill <= 0.02 ? 2.0 : 7.0;
    const waveLengthFactor = 1.3;

    // 1. Draw Background Deeper Wave (Slower, offset phase, azure tint)
    final backPath = Path();
    backPath.moveTo(0, height);
    for (double x = 0; x <= width; x += 1.5) {
      final y = waterLevelY +
          math.sin((x / (width * waveLengthFactor) * 2 * math.pi) +
                  wavePhase * 0.8 +
                  math.pi / 2) *
              (amplitude * 0.85);
      if (x == 0) {
        backPath.lineTo(x, y);
      } else {
        backPath.lineTo(x, y);
      }
    }
    backPath.lineTo(width, height);
    backPath.close();

    final backPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.azureAccent.withValues(alpha: 0.55),
          AppColors.backgroundDark.withValues(alpha: 0.85),
        ],
      ).createShader(Rect.fromLTWH(0, waterLevelY, width, height - waterLevelY));

    canvas.drawPath(backPath, backPaint);

    // 2. Draw Foreground Primary Wave (Vibrant cyan/azure liquid)
    final frontPath = Path();
    frontPath.moveTo(0, height);
    for (double x = 0; x <= width; x += 1.5) {
      final y = waterLevelY +
          math.sin((x / (width * waveLengthFactor) * 2 * math.pi) + wavePhase) *
              amplitude;
      if (x == 0) {
        frontPath.lineTo(x, y);
      } else {
        frontPath.lineTo(x, y);
      }
    }
    frontPath.lineTo(width, height);
    frontPath.close();

    final frontPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.skyHighlight.withValues(alpha: 0.85),
          AppColors.cyanAccent.withValues(alpha: 0.85),
          AppColors.azureAccent.withValues(alpha: 0.95),
        ],
        stops: const [0.0, 0.25, 1.0],
      ).createShader(Rect.fromLTWH(0, waterLevelY, width, height - waterLevelY));

    canvas.drawPath(frontPath, frontPaint);

    // 3. Draw Water Surface Crest Light Highlight
    final crestPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.8),
          AppColors.skyHighlight,
          Colors.white.withValues(alpha: 0.2),
        ],
      ).createShader(Rect.fromLTWH(0, waterLevelY - amplitude, width, amplitude * 2));

    final crestPath = Path();
    for (double x = 0; x <= width; x += 2.0) {
      final y = waterLevelY +
          math.sin((x / (width * waveLengthFactor) * 2 * math.pi) + wavePhase) *
              amplitude;
      if (x == 0) {
        crestPath.moveTo(x, y);
      } else {
        crestPath.lineTo(x, y);
      }
    }
    canvas.drawPath(crestPath, crestPaint);

    // 4. Draw Rising Micro-Bubbles
    final bubblePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    const bubbleXOffsets = [0.28, 0.45, 0.65, 0.78, 0.38];
    const bubbleSpeeds = [1.0, 0.7, 1.2, 0.85, 1.1];
    const bubbleRadii = [2.2, 3.2, 1.8, 2.8, 2.0];

    for (int i = 0; i < bubbleXOffsets.length; i++) {
      final bubbleProgressOffset = (bubbleProgress * bubbleSpeeds[i]) % 1.0;
      final bx = width * bubbleXOffsets[i] +
          math.sin(bubbleProgressOffset * 2 * math.pi + i) * 5;
      final by = height - (height - waterLevelY) * bubbleProgressOffset;

      if (by >= waterLevelY && by <= height) {
        canvas.drawCircle(Offset(bx, by), bubbleRadii[i], bubblePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DualWavePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase ||
        oldDelegate.fillProgress != fillProgress ||
        oldDelegate.bubbleProgress != bubbleProgress;
  }
}

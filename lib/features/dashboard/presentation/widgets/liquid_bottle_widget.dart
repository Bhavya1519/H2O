import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// High-performance liquid fill widget representing an IoT smart bottle.
///
/// Features:
/// - CustomPainter stylized rounded bottle contour (cap, shoulder, cylindrical body, concave base).
/// - Dual sine-wave liquid physics with phase offset for 3D depth and illuminated crest highlight.
/// - Smooth liquid height animation via [TweenAnimationBuilder].
/// - High-contrast overlay displaying remaining volume (mL) and fill percentage.
/// - Fallback mock mode: clicking the bottle drains 50 mL sips with ripple feedback for testing without firmware.
class LiquidBottleWidget extends StatefulWidget {
  /// Maximum capacity of the physical bottle in milliliters (e.g. 750 mL).
  final int capacityMl;

  /// Initial or current water volume in milliliters.
  final int? initialVolumeMl;

  /// External volume override if driven by external state (e.g. HydrationService).
  final int? currentVolumeMl;

  /// Height of the bottle widget in logical pixels.
  final double height;

  /// Width of the bottle widget in logical pixels.
  final double width;

  /// Enable mock mode to simulate sips by tapping.
  final bool enableMockSipOnClick;

  /// Callback when a sip or refill is simulated in mock mode.
  final ValueChanged<int>? onVolumeChanged;

  const LiquidBottleWidget({
    super.key,
    this.capacityMl = 750,
    this.initialVolumeMl,
    this.currentVolumeMl,
    this.height = 340,
    this.width = 160,
    this.enableMockSipOnClick = true,
    this.onVolumeChanged,
  });

  @override
  State<LiquidBottleWidget> createState() => _LiquidBottleWidgetState();
}

class _LiquidBottleWidgetState extends State<LiquidBottleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late int _waterMl;
  double _splashMultiplier = 1.0;

  @override
  void initState() {
    super.initState();
    _waterMl = widget.currentVolumeMl ?? widget.initialVolumeMl ?? widget.capacityMl;

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant LiquidBottleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentVolumeMl != null &&
        widget.currentVolumeMl != oldWidget.currentVolumeMl) {
      _waterMl = widget.currentVolumeMl!;
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _simulateSip() {
    if (!widget.enableMockSipOnClick) return;

    setState(() {
      if (_waterMl <= 0) {
        // Auto refill if empty
        _waterMl = widget.capacityMl;
      } else {
        // Drain 50 mL
        _waterMl = math.max(0, _waterMl - 50);
      }
      _splashMultiplier = 1.8; // Trigger temporary ripple surge
    });

    widget.onVolumeChanged?.call(_waterMl);

    // Reset splash intensity back to normal
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _splashMultiplier = 1.0;
        });
      }
    });

    // Provide visual feedback
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1100),
        content: Row(
          children: [
            Icon(
              _waterMl == widget.capacityMl
                  ? Icons.autorenew_rounded
                  : Icons.local_drink_rounded,
              color: AppColors.cyanAccent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              _waterMl == widget.capacityMl
                  ? 'Bottle refilled to ${widget.capacityMl} mL'
                  : 'Sip simulated: -50 mL ($_waterMl mL remaining)',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveVolume = widget.currentVolumeMl ?? _waterMl;
    final fillRatio = (effectiveVolume / widget.capacityMl).clamp(0.0, 1.0);
    final fillPercent = (fillRatio * 100).toInt();

    return GestureDetector(
      onTap: _simulateSip,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Outer Water Glow
          Container(
            width: widget.width * 0.9,
            height: widget.height * 0.75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.width * 0.35),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyanAccent.withValues(
                    alpha: 0.18 * fillRatio,
                  ),
                  blurRadius: 40,
                  spreadRadius: 6,
                ),
                BoxShadow(
                  color: AppColors.azureAccent.withValues(
                    alpha: 0.12 * fillRatio,
                  ),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),

          // Custom Bottle Contour & Waves Canvas
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: fillRatio),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, animatedFill, _) {
              return AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) {
                  return CustomPaint(
                    size: Size(widget.width, widget.height),
                    painter: _BottlePainter(
                      wavePhase: _waveController.value * 2 * math.pi,
                      fillRatio: animatedFill,
                      splashMultiplier: _splashMultiplier,
                    ),
                  );
                },
              );
            },
          ),

          // High-Contrast Center Metric Overlay
          Positioned(
            bottom: widget.height * 0.30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.glassBorderCyan,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Volume in mL
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$effectiveVolume',
                        style: AppTypography.displaySmall.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'mL',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.skyHighlight,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  // Percentage Pill
                  const SizedBox(height: 2),
                  Text(
                    '$fillPercent% FULL',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mock Mode Interactive Hint Tag (Top Right)
          if (widget.enableMockSipOnClick)
            Positioned(
              top: widget.height * 0.08,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      size: 11,
                      color: AppColors.cyanAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'TAP TO SIP (-50mL)',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 8.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
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
}

/// CustomPainter rendering a sleek, ergonomic water bottle contour with dual sine-wave liquid
class _BottlePainter extends CustomPainter {
  final double wavePhase;
  final double fillRatio; // 0.0 to 1.0
  final double splashMultiplier;

  _BottlePainter({
    required this.wavePhase,
    required this.fillRatio,
    required this.splashMultiplier,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dimensions for bottle anatomy
    final capWidth = w * 0.36;
    final capHeight = h * 0.09;
    final neckWidth = w * 0.42;
    final neckHeight = h * 0.05;
    final shoulderTop = capHeight + neckHeight;
    final bodyTop = h * 0.28;
    final bodyBottom = h * 0.94;
    final bodyRadius = w * 0.22;

    // === 1. Construct Bottle Interior Path (Clip for Waves) ===
    final interiorPath = Path();

    // Start at top neck left
    final interiorLeft = w * 0.08;
    final interiorRight = w * 0.92;
    final interiorNeckLeft = (w - neckWidth) / 2 + 4;
    final interiorNeckRight = (w + neckWidth) / 2 - 4;

    interiorPath.moveTo(interiorNeckLeft, shoulderTop);
    // Shoulder curve right
    interiorPath.cubicTo(
      interiorNeckLeft,
      bodyTop * 0.7,
      interiorLeft,
      bodyTop * 0.85,
      interiorLeft,
      bodyTop,
    );
    // Body left side down
    interiorPath.lineTo(interiorLeft, bodyBottom - bodyRadius);
    // Bottom-left corner
    interiorPath.quadraticBezierTo(
      interiorLeft,
      bodyBottom,
      interiorLeft + bodyRadius,
      bodyBottom,
    );
    // Subtle concave base indentation
    interiorPath.quadraticBezierTo(
      w / 2,
      bodyBottom - 8,
      interiorRight - bodyRadius,
      bodyBottom,
    );
    // Bottom-right corner
    interiorPath.quadraticBezierTo(
      interiorRight,
      bodyBottom,
      interiorRight,
      bodyBottom - bodyRadius,
    );
    // Body right side up
    interiorPath.lineTo(interiorRight, bodyTop);
    // Shoulder curve back to neck right
    interiorPath.cubicTo(
      interiorRight,
      bodyTop * 0.85,
      interiorNeckRight,
      bodyTop * 0.7,
      interiorNeckRight,
      shoulderTop,
    );
    interiorPath.close();

    // === 2. Render Interior Liquid Waves (Clipped) ===
    if (fillRatio > 0.005) {
      canvas.save();
      canvas.clipPath(interiorPath);

      final liquidAreaHeight = bodyBottom - shoulderTop;
      final waterLevelY = bodyBottom - (liquidAreaHeight * fillRatio);

      // Dampen waves when almost empty or completely full
      final dampening = math.sin(fillRatio * math.pi).clamp(0.2, 1.0);
      final amplitude = (5.0 * dampening * splashMultiplier).clamp(1.5, 9.0);
      final frequency = (2 * math.pi) / (w * 1.15);

      // --- 2a. Back Wave (Depth layer, offset phase, azure tint) ---
      final backWavePath = Path();
      backWavePath.moveTo(0, h);
      for (double x = 0; x <= w; x += 2.0) {
        // Back wave: y = sin(x * frequency + phase2) * amplitude
        final y = waterLevelY +
            math.sin(x * frequency + (wavePhase * 0.85) + (math.pi / 2)) *
                (amplitude * 0.8);
        if (x == 0) {
          backWavePath.lineTo(x, y);
        } else {
          backWavePath.lineTo(x, y);
        }
      }
      backWavePath.lineTo(w, h);
      backWavePath.close();

      final backPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.azureAccent.withValues(alpha: 0.55),
            AppColors.backgroundDark.withValues(alpha: 0.9),
          ],
        ).createShader(Rect.fromLTWH(0, waterLevelY, w, h - waterLevelY));

      canvas.drawPath(backWavePath, backPaint);

      // --- 2b. Front Wave (Primary liquid layer, vibrant cyan) ---
      final frontWavePath = Path();
      frontWavePath.moveTo(0, h);
      for (double x = 0; x <= w; x += 2.0) {
        // Front wave: y = sin(x * frequency + phase1) * amplitude
        final y = waterLevelY + math.sin(x * frequency + wavePhase) * amplitude;
        if (x == 0) {
          frontWavePath.lineTo(x, y);
        } else {
          frontWavePath.lineTo(x, y);
        }
      }
      frontWavePath.lineTo(w, h);
      frontWavePath.close();

      final frontPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.skyHighlight.withValues(alpha: 0.88),
            AppColors.cyanAccent.withValues(alpha: 0.90),
            AppColors.azureAccent.withValues(alpha: 0.96),
          ],
          stops: const [0.0, 0.35, 1.0],
        ).createShader(Rect.fromLTWH(0, waterLevelY, w, h - waterLevelY));

      canvas.drawPath(frontWavePath, frontPaint);

      // --- 2c. Illuminated Wave Crest Stroke ---
      final crestPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.95),
            AppColors.skyHighlight,
            Colors.white.withValues(alpha: 0.3),
          ],
        ).createShader(Rect.fromLTWH(0, waterLevelY - amplitude, w, amplitude * 2));

      final crestPath = Path();
      for (double x = 0; x <= w; x += 2.0) {
        final y = waterLevelY + math.sin(x * frequency + wavePhase) * amplitude;
        if (x == 0) {
          crestPath.moveTo(x, y);
        } else {
          crestPath.lineTo(x, y);
        }
      }
      canvas.drawPath(crestPath, crestPaint);

      canvas.restore();
    }

    // === 3. Draw Stylized Bottle Glass Contour & Highlight Reflections ===

    // Frosted glass bottle fill (translucent background inside contour)
    final glassFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.07),
          Colors.white.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(interiorPath, glassFillPaint);

    // Prismatic Glass Contour Stroke
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.65),
          AppColors.glassBorderCyan,
          AppColors.glassBorder,
          Colors.white.withValues(alpha: 0.4),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(interiorPath, borderPaint);

    // Right-edge Optical Glass Specular Highlight Arc
    final highlightPath = Path();
    highlightPath.moveTo(interiorRight - 5, bodyTop + 14);
    highlightPath.lineTo(interiorRight - 5, bodyBottom - bodyRadius);

    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.45),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, bodyTop, w, bodyBottom - bodyTop));
    canvas.drawPath(highlightPath, highlightPaint);

    // === 4. Draw Precision IoT Bottle Cap ===
    final capRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w / 2, capHeight / 2 + 6),
        width: capWidth,
        height: capHeight,
      ),
      const Radius.circular(8),
    );

    // Cap Gradient
    final capPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF334155),
          Color(0xFF1E293B),
          Color(0xFF0F172A),
        ],
      ).createShader(capRect.outerRect);
    canvas.drawRRect(capRect, capPaint);

    // Cap Border
    final capBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.glassBorderCyan;
    canvas.drawRRect(capRect, capBorderPaint);

    // Cap Accent LED Ring (Glowing Emerald / Cyan connectivity light)
    final ledRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w / 2, capHeight / 2 + 6),
        width: capWidth * 0.65,
        height: 3,
      ),
      const Radius.circular(2),
    );
    final ledPaint = Paint()
      ..color = AppColors.cyanAccent
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);
    canvas.drawRRect(ledRect, ledPaint);
  }

  @override
  bool shouldRepaint(covariant _BottlePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase ||
        oldDelegate.fillRatio != fillRatio ||
        oldDelegate.splashMultiplier != splashMultiplier;
  }
}


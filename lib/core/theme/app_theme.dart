import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Premium, Dark-Mode-First Theme Definition for H2O IoT Hydration Tracker.
///
/// Features:
/// - Deep slate/obsidian palette with vibrant liquid cyan/azure & emerald accents.
/// - Modern typography hierarchy with specialized metric styles.
/// - Reusable glassmorphic decorations and widgets with backdrop blur and gradient borders.
/// - Type-safe [AuraThemeExtension] for custom IoT and liquid hydration styling.
class AppColors {
  AppColors._();

  // === Base Backgrounds ===
  /// Deep obsidian / slate base background (#0F172A)
  static const Color background = Color(0xFF0F172A);

  /// Even deeper tone for ambient shadows and app bar depth (#090D16)
  static const Color backgroundDark = Color(0xFF090D16);

  /// Card & elevation background (#1E293B)
  static const Color surface = Color(0xFF1E293B);

  /// Frosted glass background tint
  static const Color glassSurface = Color(0x1F1E293B);
  static const Color glassSurfaceLight = Color(0x14FFFFFF);

  // === Primary Liquid Accents (Cyan to Azure) ===
  /// Vibrant Cyan liquid accent (#06B6D4)
  static const Color cyanAccent = Color(0xFF06B6D4);

  /// Deep Azure liquid accent (#3B82F6)
  static const Color azureAccent = Color(0xFF3B82F6);

  /// Light sky blue for glowing wave highlights (#38BDF8)
  static const Color skyHighlight = Color(0xFF38BDF8);

  // === Secondary & IoT Status Accents ===
  /// Vitality & goal achieved emerald accent (#10B981)
  static const Color emeraldAccent = Color(0xFF10B981);

  /// Hydration alert / reminder amber (#F59E0B)
  static const Color amberWarning = Color(0xFFF59E0B);

  /// Critical thirst / IoT disconnect rose (#F43F5E)
  static const Color roseError = Color(0xFFF43F5E);

  // === Glassmorphic Borders & Highlights ===
  static const Color glassBorder = Color(0x26FFFFFF);
  static const Color glassBorderSubtle = Color(0x14FFFFFF);
  static const Color glassBorderCyan = Color(0x4006B6D4);

  // === Typography Text Colors ===
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textCyanHighlight = Color(0xFF67E8F9);

  // === Signature Gradients ===
  /// Primary liquid gradient (Cyan -> Azure) for gauges, water levels, and CTAs
  static const LinearGradient liquidGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyanAccent, azureAccent],
  );

  /// Vertical liquid depth gradient
  static const LinearGradient liquidVerticalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyHighlight, cyanAccent, azureAccent],
  );

  /// Emerald milestone achievement gradient
  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34D399), emeraldAccent, Color(0xFF059669)],
  );

  /// Subtle frosted glass surface gradient
  static const LinearGradient glassSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1EFFFFFF),
      Color(0x0AFFFFFF),
    ],
  );

  /// Prismatic glass border gradient
  static const LinearGradient glassBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x50FFFFFF),
      Color(0x10FFFFFF),
      Color(0x4006B6D4),
    ],
  );
}

/// Modern typography hierarchy tailored for AuraDrop.
/// Includes standard Material typography plus high-legibility metric styles.
class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Roboto'; // Standard cross-platform fallback

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 54,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 42,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.5,
    color: AppColors.textMuted,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textMuted,
  );

  // === Specialized Metric Typography ===
  /// Massive numeral for current volume (e.g. "2,450")
  static const TextStyle metricValue = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    color: AppColors.textPrimary,
  );

  /// Unit label next to metric (e.g. "ml", "oz")
  static const TextStyle metricUnit = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textCyanHighlight,
  );

  /// Metric status caption (e.g. "78% OF DAILY GOAL")
  static const TextStyle metricCaption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.textSecondary,
  );

  static TextTheme get textTheme => const TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}

/// Glassmorphism design utility providing reusable frosted glass decoration,
/// custom gradients, subtle borders, and the [GlassmorphicCard] widget.
class AppGlass {
  AppGlass._();

  /// Default backdrop blur intensity
  static const double defaultBlur = 16.0;

  /// Default glass corner radius
  static const double defaultRadius = 24.0;

  /// Reusable [BoxDecoration] for glass surfaces.
  /// Note: Wrap with [BackdropFilter] or use [GlassmorphicCard] for true optical blur.
  static BoxDecoration decoration({
    double borderRadius = defaultRadius,
    Color? surfaceColor,
    Gradient? surfaceGradient,
    Gradient? borderGradient,
    Color? borderColor,
    double borderWidth = 1.0,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: surfaceGradient ?? AppColors.glassSurfaceGradient,
      color: surfaceColor,
      border: borderGradient == null
          ? Border.all(
              color: borderColor ?? AppColors.glassBorder,
              width: borderWidth,
            )
          : null,
      boxShadow: shadows ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
    );
  }
}

/// A reusable glassmorphic container widget featuring backdrop blur,
/// subtle frosted gradients, and glowing prismatic borders.
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Gradient? surfaceGradient;
  final Gradient? borderGradient;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = AppGlass.defaultRadius,
    this.blur = AppGlass.defaultBlur,
    this.surfaceGradient,
    this.borderGradient,
    this.borderColor,
    this.borderWidth = 1.2,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: surfaceGradient ?? AppColors.glassSurfaceGradient,
      ),
      child: child,
    );

    // Apply interactive tap if requested
    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          splashColor: AppColors.cyanAccent.withValues(alpha: 0.15),
          highlightColor: AppColors.azureAccent.withValues(alpha: 0.1),
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.cyanAccent.withValues(alpha: 0.04),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: CustomPaint(
            painter: _GlassBorderPainter(
              borderRadius: borderRadius,
              borderWidth: borderWidth,
              gradient: borderGradient ?? AppColors.glassBorderGradient,
              solidColor: borderColor,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Custom painter that renders a smooth gradient stroke along the border of the glass card.
class _GlassBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;
  final Gradient? gradient;
  final Color? solidColor;

  _GlassBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    this.gradient,
    this.solidColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(borderWidth / 2),
      Radius.circular(borderRadius),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    if (gradient != null) {
      paint.shader = gradient!.createShader(rect);
    } else {
      paint.color = solidColor ?? AppColors.glassBorder;
    }

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GlassBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.gradient != gradient ||
        oldDelegate.solidColor != solidColor;
  }
}

/// ThemeExtension to enable clean, strongly-typed access to AuraDrop custom styles
/// via `Theme.of(context).extension<AuraThemeExtension>()` or `context.aura`.
@immutable
class AuraThemeExtension extends ThemeExtension<AuraThemeExtension> {
  final Color cyanAccent;
  final Color azureAccent;
  final Color emeraldAccent;
  final Color backgroundDark;
  final TextStyle metricValue;
  final TextStyle metricUnit;
  final TextStyle metricCaption;
  final LinearGradient liquidGradient;
  final LinearGradient emeraldGradient;

  const AuraThemeExtension({
    required this.cyanAccent,
    required this.azureAccent,
    required this.emeraldAccent,
    required this.backgroundDark,
    required this.metricValue,
    required this.metricUnit,
    required this.metricCaption,
    required this.liquidGradient,
    required this.emeraldGradient,
  });

  static const AuraThemeExtension dark = AuraThemeExtension(
    cyanAccent: AppColors.cyanAccent,
    azureAccent: AppColors.azureAccent,
    emeraldAccent: AppColors.emeraldAccent,
    backgroundDark: AppColors.backgroundDark,
    metricValue: AppTypography.metricValue,
    metricUnit: AppTypography.metricUnit,
    metricCaption: AppTypography.metricCaption,
    liquidGradient: AppColors.liquidGradient,
    emeraldGradient: AppColors.emeraldGradient,
  );

  @override
  ThemeExtension<AuraThemeExtension> copyWith({
    Color? cyanAccent,
    Color? azureAccent,
    Color? emeraldAccent,
    Color? backgroundDark,
    TextStyle? metricValue,
    TextStyle? metricUnit,
    TextStyle? metricCaption,
    LinearGradient? liquidGradient,
    LinearGradient? emeraldGradient,
  }) {
    return AuraThemeExtension(
      cyanAccent: cyanAccent ?? this.cyanAccent,
      azureAccent: azureAccent ?? this.azureAccent,
      emeraldAccent: emeraldAccent ?? this.emeraldAccent,
      backgroundDark: backgroundDark ?? this.backgroundDark,
      metricValue: metricValue ?? this.metricValue,
      metricUnit: metricUnit ?? this.metricUnit,
      metricCaption: metricCaption ?? this.metricCaption,
      liquidGradient: liquidGradient ?? this.liquidGradient,
      emeraldGradient: emeraldGradient ?? this.emeraldGradient,
    );
  }

  @override
  ThemeExtension<AuraThemeExtension> lerp(
    covariant ThemeExtension<AuraThemeExtension>? other,
    double t,
  ) {
    if (other is! AuraThemeExtension) return this;
    return AuraThemeExtension(
      cyanAccent: Color.lerp(cyanAccent, other.cyanAccent, t)!,
      azureAccent: Color.lerp(azureAccent, other.azureAccent, t)!,
      emeraldAccent: Color.lerp(emeraldAccent, other.emeraldAccent, t)!,
      backgroundDark: Color.lerp(backgroundDark, other.backgroundDark, t)!,
      metricValue: TextStyle.lerp(metricValue, other.metricValue, t)!,
      metricUnit: TextStyle.lerp(metricUnit, other.metricUnit, t)!,
      metricCaption: TextStyle.lerp(metricCaption, other.metricCaption, t)!,
      liquidGradient: LinearGradient.lerp(liquidGradient, other.liquidGradient, t)!,
      emeraldGradient: LinearGradient.lerp(emeraldGradient, other.emeraldGradient, t)!,
    );
  }
}

/// Convenience extension on [BuildContext] for ergonomic access to Aura styles.
extension AuraContextExtension on BuildContext {
  AuraThemeExtension get aura =>
      Theme.of(this).extension<AuraThemeExtension>() ?? AuraThemeExtension.dark;

  TextTheme get textTheme => Theme.of(this).textTheme;
}

/// The main entry point for the AuraDrop theme.
class AppTheme {
  AppTheme._();

  /// Primary Dark-Mode Theme for AuraDrop
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.cyanAccent,
        onPrimary: AppColors.backgroundDark,
        secondary: AppColors.azureAccent,
        onSecondary: Colors.white,
        tertiary: AppColors.emeraldAccent,
        onTertiary: Colors.white,
        error: AppColors.roseError,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: Color(0xFF334155),
        outline: AppColors.glassBorder,
      ),
      textTheme: AppTypography.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineSmall,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface.withValues(alpha: 0.7),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppGlass.defaultRadius),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyanAccent,
          foregroundColor: AppColors.backgroundDark,
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: AppColors.cyanAccent.withValues(alpha: 0.4),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.cyanAccent,
        inactiveTrackColor: AppColors.surface,
        thumbColor: AppColors.skyHighlight,
        overlayColor: AppColors.cyanAccent.withValues(alpha: 0.2),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.cyanAccent,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AuraThemeExtension.dark,
      ],
    );
  }
}

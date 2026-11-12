import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Ultra-Premium White, Blue & Dark Blue Theme Definition for H2O Hydration Tracker.
///
/// Features:
/// - Crisp, luminous ice-white base with electric royal blues and rich midnight navy accents.
/// - Modern typography hierarchy with dark navy (#0F172A) text for maximum legibility.
/// - Floating glassmorphic containers with soft diffuse shadows and delicate blue border gradients.
/// - Type-safe [AuraThemeExtension] for custom IoT and hydration aesthetics.
class AppColors {
  AppColors._();

  // === Base Light Backgrounds ===
  /// Crisp ice white base background (#F8FAFC)
  static const Color background = Color(0xFFF8FAFC);

  /// Deep midnight navy for caps, high-contrast badges, and dark accents (#0F172A)
  static const Color backgroundDark = Color(0xFF0F172A);

  /// Secondary soft slate background (#F1F5F9)
  static const Color backgroundSecondary = Color(0xFFF1F5F9);

  /// Pure crisp white for cards, sheets, and elevated surfaces (#FFFFFF)
  static const Color surface = Color(0xFFFFFFFF);

  /// Subtle container tint for text fields and chips (#F1F5F9)
  static const Color surfaceSubtle = Color(0xFFF1F5F9);

  /// Frosted glass background tint (luminous white with 88% opacity)
  static const Color glassSurface = Color(0xE0FFFFFF);
  static const Color glassSurfaceLight = Color(0xB8FFFFFF);

  // === Primary & Accent Blues (White, Blue, Dark Blue Palette) ===
  /// Electric Royal Blue primary accent (#2563EB)
  static const Color primaryBlue = Color(0xFF2563EB);

  /// Deep Royal Navy accent (#1E3A8A)
  static const Color darkBlue = Color(0xFF1E3A8A);

  /// Midnight Blue / Obsidian Navy (#0F172A)
  static const Color midnightNavy = Color(0xFF0F172A);

  /// Vibrant Ocean/Sky Blue (#0284C7)
  static const Color cyanAccent = Color(0xFF0284C7);

  /// Deep Azure liquid accent (#2563EB)
  static const Color azureAccent = Color(0xFF2563EB);

  /// Luminous light sky highlight for reflections (#38BDF8)
  static const Color skyHighlight = Color(0xFF38BDF8);

  /// Soft ice-blue container surface (#EFF6FF)
  static const Color iceBlueSurface = Color(0xFFEFF6FF);

  // === Status Accents ===
  /// Vitality & goal achieved emerald accent (#059669)
  static const Color emeraldAccent = Color(0xFF059669);

  /// Hydration reminder amber (#D97706)
  static const Color amberWarning = Color(0xFFD97706);

  /// Disconnect / alert rose (#E11D48)
  static const Color roseError = Color(0xFFE11D48);

  // === Glassmorphic Borders & Highlights ===
  /// Delicate royal blue frosted glass border
  static const Color glassBorder = Color(0x1F2563EB);
  static const Color glassBorderSubtle = Color(0x0F0F172A);
  static const Color glassBorderCyan = Color(0x332563EB);

  // === Typography Text Colors (High Contrast on White) ===
  /// Deep midnight navy primary text (#0F172A)
  static const Color textPrimary = Color(0xFF0F172A);

  /// Slate navy secondary text (#334155)
  static const Color textSecondary = Color(0xFF334155);

  /// Muted slate supporting text (#64748B)
  static const Color textMuted = Color(0xFF64748B);

  /// Electric blue highlight text (#2563EB)
  static const Color textCyanHighlight = Color(0xFF2563EB);

  // === Signature Gradients ===
  /// Vibrant fluid blue gradient (Sky/Ocean -> Royal Blue)
  static const LinearGradient liquidGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
  );

  /// Deep 3D fluid depth gradient
  static const LinearGradient liquidVerticalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyHighlight, cyanAccent, azureAccent],
  );

  /// Royal navy to midnight blue gradient
  static const LinearGradient darkBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
  );

  /// Fresh emerald milestone gradient
  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
  );

  /// Luminous frosted ceramic white surface gradient
  static const LinearGradient glassSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xF8F8FAFC),
    ],
  );

  /// Delicate blue-edged prismatic border gradient
  static const LinearGradient glassBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x603B82F6),
      Color(0x1A2563EB),
      Color(0x401D4ED8),
    ],
  );
}

/// Modern typography hierarchy tailored for the white & dark blue aesthetic.
class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Roboto';

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
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
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
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.5,
    color: AppColors.textMuted,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
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
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textMuted,
  );

  // === Specialized Metric Typography ===
  static const TextStyle metricValue = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle metricUnit = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textCyanHighlight,
  );

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

/// Glassmorphism utility providing reusable frosted glass decoration with soft shadows.
class AppGlass {
  AppGlass._();

  static const double defaultBlur = 16.0;
  static const double defaultRadius = 24.0;

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
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.04),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
    );
  }
}

/// Reusable glassmorphic container widget featuring backdrop blur and delicate blue border gradients.
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

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          splashColor: AppColors.primaryBlue.withValues(alpha: 0.1),
          highlightColor: AppColors.cyanAccent.withValues(alpha: 0.05),
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
                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.04),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 8),
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

  static const AuraThemeExtension light = AuraThemeExtension(
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

extension AuraContextExtension on BuildContext {
  AuraThemeExtension get aura =>
      Theme.of(this).extension<AuraThemeExtension>() ?? AuraThemeExtension.light;

  TextTheme get textTheme => Theme.of(this).textTheme;
}

/// The main entry point for the H2O theme.
class AppTheme {
  AppTheme._();

  /// Primary Theme: White, Blue & Dark Blue
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryBlue,
        onPrimary: Colors.white,
        secondary: AppColors.cyanAccent,
        onSecondary: Colors.white,
        tertiary: AppColors.emeraldAccent,
        onTertiary: Colors.white,
        error: AppColors.roseError,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: Color(0xFFF1F5F9),
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
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppGlass.defaultRadius),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          textStyle: AppTypography.labelLarge.copyWith(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: AppColors.primaryBlue.withValues(alpha: 0.35),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryBlue,
        inactiveTrackColor: AppColors.surfaceSubtle,
        thumbColor: AppColors.azureAccent,
        overlayColor: AppColors.primaryBlue.withValues(alpha: 0.15),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AuraThemeExtension.light,
      ],
    );
  }

  /// Alias for backward compatibility ensuring the premium White/Blue theme is default
  static ThemeData get darkTheme => lightTheme;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/hydration_service.dart';

/// Glassmorphic hourly intake rhythm chart displaying drinking consistency
class HourlyIntakeChart extends StatelessWidget {
  final List<HourlyIntake> history;

  const HourlyIntakeChart({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final maxAmount = history.isEmpty
        ? 500
        : history.map((e) => e.amountMl).reduce(math.max);

    return GlassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title & Rhythm Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HOURLY RHYTHM',
                    style: AppTypography.metricCaption.copyWith(
                      color: AppColors.textCyanHighlight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Intake Distribution',
                    style: AppTypography.titleMedium,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.emeraldAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.emeraldAccent.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: AppColors.emeraldAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Optimal',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.emeraldAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Bar Chart Columns
          SizedBox(
            height: 130,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: history.map((item) {
                final ratio = maxAmount > 0 ? (item.amountMl / maxAmount) : 0.0;
                final barHeight = (ratio * 80).clamp(12.0, 80.0);
                final isPeak = item.amountMl == maxAmount;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Amount tooltip label
                    Text(
                      '${item.amountMl}',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 9,
                        color: isPeak ? AppColors.cyanAccent : AppColors.textMuted,
                        fontWeight: isPeak ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Liquid Bar
                    Container(
                      width: 22,
                      height: barHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: isPeak
                            ? AppColors.liquidGradient
                            : LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primaryBlue.withValues(alpha: 0.6),
                                  const Color(0xFFE2E8F0),
                                ],
                              ),
                        boxShadow: isPeak
                            ? [
                                BoxShadow(
                                  color: AppColors.cyanAccent.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Hour label
                    Text(
                      item.label,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}


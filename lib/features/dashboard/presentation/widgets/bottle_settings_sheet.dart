import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/hydration_service.dart';

/// Modal bottom sheet displaying H2O IoT bottle hardware diagnostics, UV-C cleaning, and settings
class BottleSettingsSheet extends StatelessWidget {
  final HydrationService service;

  const BottleSettingsSheet({
    super.key,
    required this.service,
  });

  static Future<void> show(BuildContext context, HydrationService service) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BottleSettingsSheet(service: service),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.only(
            top: 16,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sheet Grab Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title and Connection Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HARDWARE TELEMETRY',
                        style: AppTypography.metricCaption.copyWith(
                          color: AppColors.textCyanHighlight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        service.connectedDeviceName,
                        style: AppTypography.headlineSmall,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: service.isConnected
                          ? AppColors.emeraldAccent.withValues(alpha: 0.15)
                          : AppColors.roseError.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: service.isConnected
                            ? AppColors.emeraldAccent.withValues(alpha: 0.4)
                            : AppColors.roseError.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      service.isConnected ? 'CONNECTED' : 'DISCONNECTED',
                      style: AppTypography.labelSmall.copyWith(
                        color: service.isConnected
                            ? AppColors.emeraldAccent
                            : AppColors.roseError,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Device Specs Card
              GlassmorphicCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSpecItem(
                      Icons.battery_charging_full_rounded,
                      '${service.batteryPercent}%',
                      'Battery',
                      AppColors.emeraldAccent,
                    ),
                    Container(width: 1, height: 36, color: AppColors.glassBorder),
                    _buildSpecItem(
                      Icons.memory_rounded,
                      service.firmwareVersion,
                      'Firmware',
                      AppColors.cyanAccent,
                    ),
                    Container(width: 1, height: 36, color: AppColors.glassBorder),
                    _buildSpecItem(
                      Icons.local_drink_rounded,
                      '${service.bottleCapacityMl}ml',
                      'Capacity',
                      AppColors.azureAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // UV-C Sterilization Action Card
              GlassmorphicCard(
                padding: const EdgeInsets.all(18),
                borderColor: service.isSterilizing ? const Color(0xFFA855F7) : null,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: service.isSterilizing
                            ? const Color(0xFFA855F7).withValues(alpha: 0.2)
                            : AppColors.surface,
                      ),
                      child: Icon(
                        Icons.cleaning_services_rounded,
                        color: service.isSterilizing
                            ? const Color(0xFFA855F7)
                            : AppColors.skyHighlight,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.isSterilizing
                                ? 'UV-C Cleanse Running...'
                                : 'UV-C Self-Sterilization',
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            service.isSterilizing
                                ? '${service.sterilizationSecondsRemaining}s remaining • Purifying water'
                                : '99.9% germicidal purification cycle',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: service.isSterilizing
                          ? null
                          : () => service.startUvcSterilization(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: service.isSterilizing
                            ? const Color(0xFFA855F7)
                            : AppColors.cyanAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        service.isSterilizing ? 'Active' : 'Clean',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.backgroundDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // LED Glow Reminder Interval
              Text(
                'LED GLOW REMINDER CADENCE',
                style: AppTypography.metricCaption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [30, 45, 60, 90].map((interval) {
                  final isSelected = service.reminderIntervalMinutes == interval;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => service.setReminderInterval(interval),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.cyanAccent.withValues(alpha: 0.18)
                                : AppColors.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.cyanAccent
                                  : AppColors.glassBorder,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${interval}m',
                              style: AppTypography.labelSmall.copyWith(
                                color: isSelected
                                    ? AppColors.cyanAccent
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Close / Done button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.glassBorder),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecItem(
    IconData icon,
    String value,
    String label,
    Color accentColor,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: accentColor),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

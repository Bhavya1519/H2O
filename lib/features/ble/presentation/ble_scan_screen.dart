import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

/// Model representing a discovered smart bottle IoT device
class BleBottleDevice {
  final String id;
  final String name;
  final String model;
  final int rssi;
  final int battery;
  final bool isPaired;

  const BleBottleDevice({
    required this.id,
    required this.name,
    required this.model,
    required this.rssi,
    required this.battery,
    this.isPaired = false,
  });
}

/// BLE Scan Screen to discover, pair, and connect with AuraDrop smart bottles.
class BleScanScreen extends StatefulWidget {
  const BleScanScreen({super.key});

  @override
  State<BleScanScreen> createState() => _BleScanScreenState();
}

class _BleScanScreenState extends State<BleScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  bool _isConnecting = false;
  String? _connectingDeviceId;

  final List<BleBottleDevice> _devices = const [
    BleBottleDevice(
      id: 'AD-PRO-9842',
      name: 'AuraBottle Pro',
      model: '750ml • Titanium Obsidian',
      rssi: -48,
      battery: 92,
      isPaired: true,
    ),
    BleBottleDevice(
      id: 'AD-MINI-1104',
      name: 'AuraHydrate Mini',
      model: '500ml • Glacier Cyan',
      rssi: -72,
      battery: 64,
    ),
    BleBottleDevice(
      id: 'AD-PRO-3321',
      name: 'AuraBottle Pro (Living Room)',
      model: '750ml • Cobalt Azure',
      rssi: -84,
      battery: 88,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  Future<void> _connectToDevice(BleBottleDevice device) async {
    setState(() {
      _isConnecting = true;
      _connectingDeviceId = device.id;
    });

    // Simulate BLE handshake & characteristic subscription
    await Future.delayed(const Duration(milliseconds: 1400));

    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bluetooth Pairing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/login'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.surface,
                  content: Text(
                    'Scanning for nearby Aura bottles...',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.cyanAccent,
                    ),
                  ),
                  duration: const Duration(milliseconds: 1200),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background ambient gradient
          Positioned(
            top: -40,
            left: MediaQuery.of(context).size.width / 2 - 150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyanAccent.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Radar scanning animation
                SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Expanding ripple circles
                      AnimatedBuilder(
                        animation: _radarController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: List.generate(3, (index) {
                              final progress = (_radarController.value + (index / 3)) % 1.0;
                              return Container(
                                width: progress * 220,
                                height: progress * 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.cyanAccent.withValues(
                                      alpha: (1.0 - progress) * 0.45,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),

                      // Central Bluetooth Hub Icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.liquidGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyanAccent.withValues(alpha: 0.4),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bluetooth_audio_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  'SCANNING FOR NEARBY DEVICES',
                  style: AppTypography.metricCaption.copyWith(
                    color: AppColors.textCyanHighlight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hold your AuraBottle near your phone',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Discovered Devices List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: _devices.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      final isCurrentTarget = _connectingDeviceId == device.id;

                      return GlassmorphicCard(
                        padding: const EdgeInsets.all(18),
                        onTap: _isConnecting ? null : () => _connectToDevice(device),
                        borderColor: isCurrentTarget ? AppColors.cyanAccent : null,
                        borderWidth: isCurrentTarget ? 1.8 : 1.0,
                        child: Row(
                          children: [
                            // Bottle Model Avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: AppColors.surface,
                                border: Border.all(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              child: Icon(
                                Icons.local_drink_rounded,
                                color: isCurrentTarget
                                    ? AppColors.cyanAccent
                                    : AppColors.skyHighlight,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Device Specs
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        device.name,
                                        style: AppTypography.titleSmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (device.isPaired) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.emeraldAccent.withValues(alpha: 0.18),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'PAIRED',
                                            style: AppTypography.labelSmall.copyWith(
                                              fontSize: 9,
                                              color: AppColors.emeraldAccent,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    device.model,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // Battery & RSSI stats
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.battery_5_bar_rounded,
                                        size: 14,
                                        color: device.battery > 70
                                            ? AppColors.emeraldAccent
                                            : AppColors.amberWarning,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${device.battery}%',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      const Icon(
                                        Icons.wifi_tethering_rounded,
                                        size: 14,
                                        color: AppColors.cyanAccent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${device.rssi} dBm',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Action button / Spinner
                            if (isCurrentTarget)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: AppColors.cyanAccent,
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.liquidGradient,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Connect',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Manual Skip to Dashboard
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextButton.icon(
                    onPressed: () => context.go('/dashboard'),
                    icon: const Icon(
                      Icons.dashboard_customize_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    label: Text(
                      'Preview Dashboard Offline',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

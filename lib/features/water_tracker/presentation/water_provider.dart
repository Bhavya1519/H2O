import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connection status enum for the IoT smart water bottle.
enum BottleConnectionStatus {
  disconnected,
  scanning,
  connected;

  bool get isConnected => this == BottleConnectionStatus.connected;
  bool get isScanning => this == BottleConnectionStatus.scanning;
  bool get isDisconnected => this == BottleConnectionStatus.disconnected;
}

/// Immutable data state holding smart bottle telemetry and hydration tracking.
@immutable
class WaterBottleState {
  /// BLE connection status (disconnected, scanning, connected).
  final BottleConnectionStatus connectionStatus;

  /// Current fluid volume inside the bottle in milliliters.
  final int currentVolumeMl;

  /// Total maximum volume capacity in milliliters (default: 1000 mL).
  final int totalCapacityMl;

  /// Hardware battery percentage remaining (0 to 100).
  final int batteryPercent;

  /// Fluid volume (in mL) consumed in the most recently detected sip.
  final int lastSipAmount;

  /// Total cumulative fluid volume (in mL) consumed today.
  final int todayTotalConsumedMl;

  const WaterBottleState({
    this.connectionStatus = BottleConnectionStatus.disconnected,
    this.currentVolumeMl = 1000,
    this.totalCapacityMl = 1000,
    this.batteryPercent = 100,
    this.lastSipAmount = 0,
    this.todayTotalConsumedMl = 0,
  });

  /// Percentage of total capacity filled with water (0.0 to 1.0).
  double get fillRatio => totalCapacityMl > 0
      ? (currentVolumeMl / totalCapacityMl).clamp(0.0, 1.0)
      : 0.0;

  /// Fill percentage as an integer (0 to 100).
  int get fillPercentage => (fillRatio * 100).round();

  /// Creates a copy of this state with specified fields replaced.
  WaterBottleState copyWith({
    BottleConnectionStatus? connectionStatus,
    int? currentVolumeMl,
    int? totalCapacityMl,
    int? batteryPercent,
    int? lastSipAmount,
    int? todayTotalConsumedMl,
  }) {
    return WaterBottleState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      currentVolumeMl: currentVolumeMl ?? this.currentVolumeMl,
      totalCapacityMl: totalCapacityMl ?? this.totalCapacityMl,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      lastSipAmount: lastSipAmount ?? this.lastSipAmount,
      todayTotalConsumedMl: todayTotalConsumedMl ?? this.todayTotalConsumedMl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterBottleState &&
          runtimeType == other.runtimeType &&
          connectionStatus == other.connectionStatus &&
          currentVolumeMl == other.currentVolumeMl &&
          totalCapacityMl == other.totalCapacityMl &&
          batteryPercent == other.batteryPercent &&
          lastSipAmount == other.lastSipAmount &&
          todayTotalConsumedMl == other.todayTotalConsumedMl;

  @override
  int get hashCode => Object.hash(
        connectionStatus,
        currentVolumeMl,
        totalCapacityMl,
        batteryPercent,
        lastSipAmount,
        todayTotalConsumedMl,
      );

  @override
  String toString() =>
      'WaterBottleState(status: ${connectionStatus.name}, volume: $currentVolumeMl/$totalCapacityMl mL, battery: $batteryPercent%, lastSip: $lastSipAmount mL, todayTotal: $todayTotalConsumedMl mL)';
}

/// Robust [AsyncNotifier] managing the smart water bottle BLE subscription,
/// raw byte stream decoding, and automatic sip detection.
class WaterBottleNotifier extends AsyncNotifier<WaterBottleState> {
  StreamSubscription<List<int>>? _characteristicSubscription;
  StreamSubscription<BluetoothConnectionState>? _deviceStateSubscription;
  bool _isBaselineEstablished = false;

  /// Minimum volume drop in mL to qualify as an intentional sip (filters sensor noise/drift).
  static const int minSipThresholdMl = 20;

  @override
  FutureOr<WaterBottleState> build() {
    // Ensure clean teardown when notifier or provider is disposed
    ref.onDispose(() {
      _cleanupSubscriptions();
    });

    return const WaterBottleState();
  }

  /// Cancels active subscriptions and resets baseline flags.
  void _cleanupSubscriptions() {
    _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
    _deviceStateSubscription?.cancel();
    _deviceStateSubscription = null;
    _isBaselineEstablished = false;
  }

  // === Byte Decoding Helpers ===

  /// Decodes raw incoming bytes into an unsigned 16-bit integer (uint16) representing volume in mL.
  /// Standard BLE GATT characteristics use little-endian byte order by default.
  static int decodeVolumeFromBytes(
    List<int> bytes, {
    Endian endian = Endian.little,
  }) {
    if (bytes.length < 2) {
      throw FormatException(
        'Invalid GATT payload length: expected at least 2 bytes for uint16 volume, received ${bytes.length} bytes',
      );
    }
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    return byteData.getUint16(0, endian);
  }

  /// Decodes optional battery level if present in byte 2 (0 - 100%).
  static int? decodeBatteryFromBytes(List<int> bytes) {
    if (bytes.length >= 3) {
      return bytes[2].clamp(0, 100);
    }
    return null;
  }

  // === Packet Processing & Sip Detection ===

  /// Parses incoming raw bytes, computes volume differences, and detects sips.
  ///
  /// Detection rules:
  /// - The first reading establishes the baseline volume without falsely triggering a sip.
  /// - If volume drops by >= [minSipThresholdMl] (20 mL), it is identified as a sip:
  ///   - `lastSipAmount` is updated to the drop amount.
  ///   - `todayTotalConsumedMl` is incremented by the drop amount.
  /// - If volume drops by < 20 mL, it is considered sensor noise (volume updates, no sip logged).
  /// - If volume increases, the bottle was refilled (volume updates, no sip logged).
  void processIncomingBytes(List<int> bytes, {Endian endian = Endian.little}) {
    if (bytes.length < 2) return;

    final newVolume = decodeVolumeFromBytes(bytes, endian: endian);
    final optionalBattery = decodeBatteryFromBytes(bytes);

    final current = state.value ?? const WaterBottleState();

    // Baseline establishment on initial packet
    if (!_isBaselineEstablished) {
      _isBaselineEstablished = true;
      state = AsyncData(
        current.copyWith(
          currentVolumeMl: newVolume,
          batteryPercent: optionalBattery ?? current.batteryPercent,
        ),
      );
      return;
    }

    final prevVolume = current.currentVolumeMl;
    int nextLastSip = current.lastSipAmount;
    int nextTodayTotal = current.todayTotalConsumedMl;

    if (newVolume < prevVolume) {
      final drop = prevVolume - newVolume;
      if (drop >= minSipThresholdMl) {
        nextLastSip = drop;
        nextTodayTotal += drop;
      }
    }

    state = AsyncData(
      current.copyWith(
        currentVolumeMl: newVolume,
        batteryPercent: optionalBattery ?? current.batteryPercent,
        lastSipAmount: nextLastSip,
        todayTotalConsumedMl: nextTodayTotal,
      ),
    );
  }

  // === BLE Characteristic Subscription ===

  /// Subscribes to the characteristic notification stream from a [BluetoothCharacteristic]
  /// and automatically manages connection state and lifecycle.
  Future<void> attachCharacteristic(
    BluetoothCharacteristic characteristic, {
    Endian endian = Endian.little,
    bool enableNotifications = true,
  }) async {
    _cleanupSubscriptions();

    final current = state.value ?? const WaterBottleState();
    state = AsyncData(
      current.copyWith(connectionStatus: BottleConnectionStatus.connected),
    );

    // Watch hardware connection state changes
    _deviceStateSubscription =
        characteristic.device.connectionState.listen((connState) {
      if (connState == BluetoothConnectionState.disconnected) {
        detachCharacteristic();
      }
    });

    if (enableNotifications) {
      try {
        await characteristic.setNotifyValue(true);
      } catch (e) {
        debugPrint('BluetoothCharacteristic.setNotifyValue notice: $e');
      }
    }

    _characteristicSubscription = characteristic.onValueReceived.listen(
      (bytes) => processIncomingBytes(bytes, endian: endian),
      onError: (Object error, StackTrace stack) {
        state = AsyncError(error, stack);
      },
      onDone: () {
        detachCharacteristic();
      },
    );
  }

  /// Subscribes directly to any byte stream (ideal for testing, mocks, or simulated hardware).
  void subscribeToByteStream(
    Stream<List<int>> byteStream, {
    Endian endian = Endian.little,
  }) {
    _cleanupSubscriptions();

    final current = state.value ?? const WaterBottleState();
    state = AsyncData(
      current.copyWith(connectionStatus: BottleConnectionStatus.connected),
    );

    _characteristicSubscription = byteStream.listen(
      (bytes) => processIncomingBytes(bytes, endian: endian),
      onError: (Object error, StackTrace stack) {
        state = AsyncError(error, stack);
      },
      onDone: () {
        detachCharacteristic();
      },
    );
  }

  /// Detaches the current characteristic and sets connectionStatus to disconnected.
  Future<void> detachCharacteristic() async {
    _cleanupSubscriptions();

    final current = state.value ?? const WaterBottleState();
    state = AsyncData(
      current.copyWith(connectionStatus: BottleConnectionStatus.disconnected),
    );
  }

  // === Manual & Mock State Mutators ===

  /// Sets the state to scanning.
  void setScanning() {
    final current = state.value ?? const WaterBottleState();
    state = AsyncData(
      current.copyWith(connectionStatus: BottleConnectionStatus.scanning),
    );
  }

  /// Manually simulates or records a consumed sip.
  void recordManualSip(int amountMl) {
    if (amountMl <= 0) return;
    final current = state.value ?? const WaterBottleState();
    final newVolume = (current.currentVolumeMl - amountMl).clamp(0, current.totalCapacityMl);

    state = AsyncData(
      current.copyWith(
        currentVolumeMl: newVolume,
        lastSipAmount: amountMl,
        todayTotalConsumedMl: current.todayTotalConsumedMl + amountMl,
      ),
    );
  }

  /// Refills the water bottle to maximum capacity.
  void refillBottle([int? capacityMl]) {
    final current = state.value ?? const WaterBottleState();
    final cap = capacityMl ?? current.totalCapacityMl;
    state = AsyncData(
      current.copyWith(
        currentVolumeMl: cap,
        totalCapacityMl: cap,
      ),
    );
  }

  /// Resets today's accumulated consumption to zero.
  void resetDailyTotal() {
    final current = state.value ?? const WaterBottleState();
    state = AsyncData(
      current.copyWith(todayTotalConsumedMl: 0, lastSipAmount: 0),
    );
  }
}

/// Global provider for [WaterBottleNotifier] holding [WaterBottleState].
final waterBottleProvider =
    AsyncNotifierProvider<WaterBottleNotifier, WaterBottleState>(
  WaterBottleNotifier.new,
);

/// Convenience provider exposing only the current fluid volume in mL.
final currentVolumeProvider = Provider<int>((ref) {
  final bottleState = ref.watch(waterBottleProvider).value;
  return bottleState?.currentVolumeMl ?? 1000;
});

/// Convenience provider exposing today's total consumed volume in mL.
final todayConsumedProvider = Provider<int>((ref) {
  final bottleState = ref.watch(waterBottleProvider).value;
  return bottleState?.todayTotalConsumedMl ?? 0;
});

/// Convenience provider exposing the last recorded sip amount in mL.
final lastSipAmountProvider = Provider<int>((ref) {
  final bottleState = ref.watch(waterBottleProvider).value;
  return bottleState?.lastSipAmount ?? 0;
});

/// Convenience provider exposing the connection status of the bottle.
final bottleConnectionStatusProvider = Provider<BottleConnectionStatus>((ref) {
  final bottleState = ref.watch(waterBottleProvider).value;
  return bottleState?.connectionStatus ?? BottleConnectionStatus.disconnected;
});

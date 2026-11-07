import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/features/water_tracker/presentation/water_provider.dart';

void main() {
  group('WaterBottleState Data Class', () {
    test('default state values are initialized properly', () {
      const state = WaterBottleState();
      expect(state.connectionStatus, BottleConnectionStatus.disconnected);
      expect(state.currentVolumeMl, 1000);
      expect(state.totalCapacityMl, 1000);
      expect(state.batteryPercent, 100);
      expect(state.lastSipAmount, 0);
      expect(state.todayTotalConsumedMl, 0);
      expect(state.fillRatio, 1.0);
      expect(state.fillPercentage, 100);
    });

    test('copyWith updates specified fields correctly', () {
      const state = WaterBottleState();
      final updated = state.copyWith(
        connectionStatus: BottleConnectionStatus.connected,
        currentVolumeMl: 650,
        batteryPercent: 88,
        lastSipAmount: 50,
        todayTotalConsumedMl: 350,
      );

      expect(updated.connectionStatus, BottleConnectionStatus.connected);
      expect(updated.currentVolumeMl, 650);
      expect(updated.totalCapacityMl, 1000);
      expect(updated.batteryPercent, 88);
      expect(updated.lastSipAmount, 50);
      expect(updated.todayTotalConsumedMl, 350);
      expect(updated.fillRatio, 0.65);
      expect(updated.fillPercentage, 65);
    });

    test('equality and hashCode contract', () {
      const state1 = WaterBottleState(
        connectionStatus: BottleConnectionStatus.connected,
        currentVolumeMl: 700,
        totalCapacityMl: 1000,
        batteryPercent: 90,
        lastSipAmount: 40,
        todayTotalConsumedMl: 300,
      );

      const state2 = WaterBottleState(
        connectionStatus: BottleConnectionStatus.connected,
        currentVolumeMl: 700,
        totalCapacityMl: 1000,
        batteryPercent: 90,
        lastSipAmount: 40,
        todayTotalConsumedMl: 300,
      );

      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
    });
  });

  group('Raw Byte Stream Decoding', () {
    test('decodes uint16 volume in little-endian byte order', () {
      // 1000 mL = 0x03E8 -> [0xE8, 0x03]
      expect(
        WaterBottleNotifier.decodeVolumeFromBytes([0xE8, 0x03]),
        1000,
      );

      // 450 mL = 0x01C2 -> [0xC2, 0x01]
      expect(
        WaterBottleNotifier.decodeVolumeFromBytes([0xC2, 0x01]),
        450,
      );

      // 0 mL = [0x00, 0x00]
      expect(
        WaterBottleNotifier.decodeVolumeFromBytes([0x00, 0x00]),
        0,
      );
    });

    test('decodes optional battery percent from 3rd byte', () {
      expect(
        WaterBottleNotifier.decodeBatteryFromBytes([0xE8, 0x03, 85]),
        85,
      );
      expect(
        WaterBottleNotifier.decodeBatteryFromBytes([0xE8, 0x03]),
        isNull,
      );
    });

    test('throws FormatException if byte array has fewer than 2 bytes', () {
      expect(
        () => WaterBottleNotifier.decodeVolumeFromBytes([0xFF]),
        throwsFormatException,
      );
    });
  });

  group('WaterBottleNotifier State Machine & Sip Detection', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initializes with default WaterBottleState in AsyncData', () {
      final asyncState = container.read(waterBottleProvider);
      expect(asyncState.hasValue, isTrue);

      final state = asyncState.requireValue;
      expect(state.connectionStatus, BottleConnectionStatus.disconnected);
      expect(state.currentVolumeMl, 1000);
      expect(state.todayTotalConsumedMl, 0);
    });

    test('establishes baseline volume on initial byte packet without counting as sip', () {
      final notifier = container.read(waterBottleProvider.notifier);

      // Initial hardware packet reporting 800 mL (0x0320 -> [0x20, 0x03])
      notifier.processIncomingBytes([0x20, 0x03, 95]);

      final state = container.read(waterBottleProvider).requireValue;
      expect(state.currentVolumeMl, 800);
      expect(state.batteryPercent, 95);
      expect(state.todayTotalConsumedMl, 0);
      expect(state.lastSipAmount, 0);
    });

    test('detects sip when volume drops by >= 20 mL', () {
      final notifier = container.read(waterBottleProvider.notifier);

      // Baseline: 800 mL
      notifier.processIncomingBytes([0x20, 0x03]);

      // Sip of 50 mL: drops to 750 mL (0x02EE -> [0xEE, 0x02])
      notifier.processIncomingBytes([0xEE, 0x02]);

      final state = container.read(waterBottleProvider).requireValue;
      expect(state.currentVolumeMl, 750);
      expect(state.lastSipAmount, 50);
      expect(state.todayTotalConsumedMl, 50);
    });

    test('ignores small volume drops < 20 mL as sensor noise', () {
      final notifier = container.read(waterBottleProvider.notifier);

      // Baseline: 750 mL
      notifier.processIncomingBytes([0xEE, 0x02]);

      // Sensor drift drop by only 10 mL: drops to 740 mL (0x02E4 -> [0xE4, 0x02])
      notifier.processIncomingBytes([0xE4, 0x02]);

      final state = container.read(waterBottleProvider).requireValue;
      expect(state.currentVolumeMl, 740);
      expect(state.lastSipAmount, 0); // No sip triggered
      expect(state.todayTotalConsumedMl, 0); // No total incremented
    });

    test('accumulates multiple consecutive sips accurately', () {
      final notifier = container.read(waterBottleProvider.notifier);

      // 1. Baseline: 1000 mL
      notifier.processIncomingBytes([0xE8, 0x03]);

      // 2. Sip 1: -60 mL -> 940 mL (0x03AC -> [0xAC, 0x03])
      notifier.processIncomingBytes([0xAC, 0x03]);
      expect(container.read(todayConsumedProvider), 60);
      expect(container.read(lastSipAmountProvider), 60);

      // 3. Sip 2: -100 mL -> 840 mL (0x0348 -> [0x48, 0x03])
      notifier.processIncomingBytes([0x48, 0x03]);
      expect(container.read(todayConsumedProvider), 160);
      expect(container.read(lastSipAmountProvider), 100);

      // 4. Noise: -5 mL -> 835 mL (0x0343 -> [0x43, 0x03])
      notifier.processIncomingBytes([0x43, 0x03]);
      expect(container.read(todayConsumedProvider), 160); // unchanged
      expect(container.read(lastSipAmountProvider), 100); // unchanged
      expect(container.read(currentVolumeProvider), 835);

      // 5. Sip 3: -35 mL -> 800 mL (0x0320 -> [0x20, 0x03])
      notifier.processIncomingBytes([0x20, 0x03]);
      expect(container.read(todayConsumedProvider), 195);
      expect(container.read(lastSipAmountProvider), 35);
      expect(container.read(currentVolumeProvider), 800);
    });

    test('handles bottle refills without triggering false sips', () {
      final notifier = container.read(waterBottleProvider.notifier);

      // Baseline: 500 mL (0x01F4 -> [0xF4, 0x01])
      notifier.processIncomingBytes([0xF4, 0x01]);

      // Sip: -70 mL -> 430 mL (0x01AE -> [0xAE, 0x01])
      notifier.processIncomingBytes([0xAE, 0x01]);
      expect(container.read(todayConsumedProvider), 70);

      // User refills bottle back to 1000 mL (0x03E8 -> [0xE8, 0x03])
      notifier.processIncomingBytes([0xE8, 0x03]);

      final state = container.read(waterBottleProvider).requireValue;
      expect(state.currentVolumeMl, 1000);
      expect(state.todayTotalConsumedMl, 70); // Consumed total preserved!
      expect(state.lastSipAmount, 70); // Last sip preserved
    });

    test('subscribeToByteStream handles continuous stream of telemetry packets',
        () async {
      final notifier = container.read(waterBottleProvider.notifier);
      final streamController = StreamController<List<int>>();

      notifier.subscribeToByteStream(streamController.stream);

      expect(
        container.read(bottleConnectionStatusProvider),
        BottleConnectionStatus.connected,
      );

      // Push baseline: 900 mL (0x0384 -> [0x84, 0x03])
      streamController.add([0x84, 0x03]);
      await pumpEventQueue();

      expect(container.read(currentVolumeProvider), 900);
      expect(container.read(todayConsumedProvider), 0);

      // Push sip: 850 mL (50 mL drop) (0x0352 -> [0x52, 0x03])
      streamController.add([0x52, 0x03]);
      await pumpEventQueue();

      expect(container.read(currentVolumeProvider), 850);
      expect(container.read(todayConsumedProvider), 50);
      expect(container.read(lastSipAmountProvider), 50);

      await streamController.close();
      await pumpEventQueue();

      // Controller closure transitions to disconnected
      expect(
        container.read(bottleConnectionStatusProvider),
        BottleConnectionStatus.disconnected,
      );
    });

    test('manual helper mutators update state reliably', () {
      final notifier = container.read(waterBottleProvider.notifier);

      notifier.setScanning();
      expect(
        container.read(bottleConnectionStatusProvider),
        BottleConnectionStatus.scanning,
      );

      notifier.recordManualSip(120);
      expect(container.read(currentVolumeProvider), 880);
      expect(container.read(todayConsumedProvider), 120);
      expect(container.read(lastSipAmountProvider), 120);

      notifier.resetDailyTotal();
      expect(container.read(todayConsumedProvider), 0);
      expect(container.read(lastSipAmountProvider), 0);

      notifier.refillBottle(1200);
      expect(container.read(currentVolumeProvider), 1200);
    });
  });
}

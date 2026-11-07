import 'dart:async';
import 'package:flutter/foundation.dart';

/// Hourly intake data point for analytics
class HourlyIntake {
  final int hour; // 24-hour format
  final int amountMl;

  const HourlyIntake({required this.hour, required this.amountMl});

  String get label {
    if (hour == 0) return '12A';
    if (hour < 12) return '${hour}A';
    if (hour == 12) return '12P';
    return '${hour - 12}P';
  }
}

/// Central state and service managing IoT bottle telemetry and hydration metrics
class HydrationService extends ChangeNotifier {
  static final HydrationService _instance = HydrationService._internal();
  factory HydrationService() => _instance;
  HydrationService._internal();

  // === Hydration Target & Current Intake ===
  int _currentIntakeMl = 2150;
  int _targetGoalMl = 2800;
  int _streakDays = 14;

  int get currentIntakeMl => _currentIntakeMl;
  int get targetGoalMl => _targetGoalMl;
  int get streakDays => _streakDays;
  double get progress => (_currentIntakeMl / _targetGoalMl).clamp(0.0, 1.0);
  int get remainingMl => (_targetGoalMl - _currentIntakeMl).clamp(0, _targetGoalMl);

  // === IoT Bottle Telemetry ===
  String _connectedDeviceName = 'H2O Bottle Pro';
  String _firmwareVersion = 'v2.4.1';
  int _batteryPercent = 92;
  double _waterTempCelsius = 16.5;
  bool _isConnected = true;
  int _bottleCapacityMl = 750;

  String get connectedDeviceName => _connectedDeviceName;
  String get firmwareVersion => _firmwareVersion;
  int get batteryPercent => _batteryPercent;
  double get waterTempCelsius => _waterTempCelsius;
  bool get isConnected => _isConnected;
  int get bottleCapacityMl => _bottleCapacityMl;

  // === UV-C Sterilization Feature ===
  bool _isSterilizing = false;
  int _sterilizationSecondsRemaining = 0;
  Timer? _sterilizationTimer;

  bool get isSterilizing => _isSterilizing;
  int get sterilizationSecondsRemaining => _sterilizationSecondsRemaining;

  // === Reminder Settings ===
  int _reminderIntervalMinutes = 45;
  int get reminderIntervalMinutes => _reminderIntervalMinutes;

  // === Hourly Log ===
  final List<HourlyIntake> _hourlyHistory = [
    const HourlyIntake(hour: 8, amountMl: 350),
    const HourlyIntake(hour: 10, amountMl: 400),
    const HourlyIntake(hour: 12, amountMl: 550),
    const HourlyIntake(hour: 14, amountMl: 300),
    const HourlyIntake(hour: 16, amountMl: 350),
    const HourlyIntake(hour: 18, amountMl: 200),
  ];

  List<HourlyIntake> get hourlyHistory => List.unmodifiable(_hourlyHistory);

  /// Log additional hydration intake (from manual button or BLE sip detection)
  void logIntake(int amountMl) {
    _currentIntakeMl = (_currentIntakeMl + amountMl).clamp(0, 6000);
    if (_currentIntakeMl >= _targetGoalMl && _streakDays == 14) {
      _streakDays = 15;
    }
    notifyListeners();
  }

  /// Update hydration daily goal
  void setTargetGoal(int goalMl) {
    _targetGoalMl = goalMl.clamp(1000, 5000);
    notifyListeners();
  }

  /// Update reminder interval
  void setReminderInterval(int minutes) {
    _reminderIntervalMinutes = minutes;
    notifyListeners();
  }

  /// Trigger UV-C bottle self-cleaning sterilization cycle (60 seconds)
  void startUvcSterilization() {
    if (_isSterilizing) return;
    _isSterilizing = true;
    _sterilizationSecondsRemaining = 60;
    notifyListeners();

    _sterilizationTimer?.cancel();
    _sterilizationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sterilizationSecondsRemaining > 1) {
        _sterilizationSecondsRemaining--;
        notifyListeners();
      } else {
        _isSterilizing = false;
        _sterilizationSecondsRemaining = 0;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  /// Update live telemetry received from bottle BLE GATT characteristics
  void updateTelemetry({
    int? battery,
    double? waterTemp,
    String? deviceName,
    String? firmware,
    int? capacity,
  }) {
    if (battery != null) _batteryPercent = battery;
    if (waterTemp != null) _waterTempCelsius = waterTemp;
    if (deviceName != null) _connectedDeviceName = deviceName;
    if (firmware != null) _firmwareVersion = firmware;
    if (capacity != null) _bottleCapacityMl = capacity;
    notifyListeners();
  }

  /// Toggle device connection simulation
  void toggleConnection() {
    _isConnected = !_isConnected;
    notifyListeners();
  }

  @override
  void dispose() {
    _sterilizationTimer?.cancel();
    super.dispose();
  }
}

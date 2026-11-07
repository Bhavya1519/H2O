import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/core/theme/app_theme.dart';
import 'package:my_flutter_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:my_flutter_app/features/dashboard/presentation/widgets/liquid_bottle_widget.dart';
import 'package:my_flutter_app/features/water_tracker/presentation/water_provider.dart';

void main() {
  testWidgets('DashboardScreen renders top status bar, bottle widget, and metric card',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          waterBottleProvider.overrideWith(
            () => _FakeWaterBottleNotifier(
              const WaterBottleState(
                connectionStatus: BottleConnectionStatus.connected,
                currentVolumeMl: 800,
                totalCapacityMl: 1000,
                batteryPercent: 88,
                lastSipAmount: 60,
                todayTotalConsumedMl: 1450,
                dailyTargetMl: 2500,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const DashboardScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 1. Verify Top Status Bar elements
    expect(find.text(' 88%'), findsOneWidget);
    expect(find.byIcon(Icons.battery_charging_full_rounded), findsOneWidget);

    // 2. Verify Center LiquidBottleWidget
    expect(find.byType(LiquidBottleWidget), findsOneWidget);
    expect(find.text('800'), findsOneWidget); // current bottle volume in center badge

    // 3. Verify Sleek Horizontal Metric Card under the bottle
    expect(find.text('DAILY TARGET PROGRESS'), findsOneWidget);
    expect(find.text('1450'), findsAtLeastNWidgets(1));
    expect(find.text(' / 2500 mL'), findsOneWidget);
    expect(find.text('LAST SIP'), findsOneWidget);
    expect(find.text('+60 mL'), findsOneWidget);

    // 4. Verify Quick Add buttons
    expect(find.text('+150'), findsOneWidget);
    expect(find.text('+250'), findsOneWidget);
    expect(find.text('+500'), findsOneWidget);
  });
}

class _FakeWaterBottleNotifier extends WaterBottleNotifier {
  final WaterBottleState _initialState;

  _FakeWaterBottleNotifier(this._initialState);

  @override
  WaterBottleState build() => _initialState;
}

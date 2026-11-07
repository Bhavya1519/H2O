import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/features/dashboard/presentation/widgets/liquid_bottle_widget.dart';

void main() {
  testWidgets('LiquidBottleWidget renders initial volume and percentage badge',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: LiquidBottleWidget(
              capacityMl: 750,
              initialVolumeMl: 550,
              enableMockSipOnClick: true,
            ),
          ),
        ),
      ),
    );

    // Initial frame
    await tester.pump();

    // Verify remaining mL is displayed
    expect(find.text('550'), findsOneWidget);
    expect(find.text('mL'), findsOneWidget);

    // Verify 73% (550 / 750 = 73%)
    expect(find.text('73% FULL'), findsOneWidget);

    // Verify interactive mock hint tag
    expect(find.text('TAP TO SIP (-50mL)'), findsOneWidget);
  });

  testWidgets('LiquidBottleWidget mock tap drains 50 mL and fires onVolumeChanged',
      (WidgetTester tester) async {
    int? reportedVolume;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LiquidBottleWidget(
              capacityMl: 750,
              initialVolumeMl: 500,
              enableMockSipOnClick: true,
              onVolumeChanged: (volume) {
                reportedVolume = volume;
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('500'), findsOneWidget);

    // Tap bottle to simulate sip
    await tester.tap(find.byType(LiquidBottleWidget));
    await tester.pump();

    // Verify volume drained by 50 mL to 450
    expect(reportedVolume, 450);
    expect(find.text('450'), findsOneWidget);
    expect(find.text('60% FULL'), findsOneWidget);

    // Pump past the snackbar and animation durations to settle cleanly
    await tester.pump(const Duration(seconds: 2));
  });
}

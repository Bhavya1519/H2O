import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app/main.dart';

void main() {
  testWidgets('AuraDropApp smoke test', (WidgetTester tester) async {
    // Build AuraDrop and trigger initial frame.
    await tester.pumpWidget(const AuraDropApp());

    // Verify that AuraDrop title renders on the splash screen
    expect(find.text('AuraDrop'), findsOneWidget);
    expect(find.text('SMART IoT HYDRATION ECOSYSTEM'), findsOneWidget);

    // Fast forward past the splash screen timer into the login screen
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify login screen is displayed after splash
    expect(find.text('Welcome to AuraDrop'), findsOneWidget);
  });
}

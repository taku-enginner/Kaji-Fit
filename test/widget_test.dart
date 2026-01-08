import 'package:flutter_test/flutter_test.dart';

import 'package:kaji_fit/main.dart';

void main() {
  testWidgets('Kaji-Fit app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KajiFitApp());

    // Verify that the workout screen is displayed
    expect(find.text('家事トレ計測'), findsOneWidget);
    expect(find.text('布団干し'), findsOneWidget);
    expect(find.text('スタート'), findsOneWidget);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:datasapien_pocketmodels/main.dart';

void main() {
  testWidgets('App shell renders', (WidgetTester tester) async {
    // Production passes [MyApp.sdkSetupFuture]; tests skip SDK wait (null default).
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MyApp), findsOneWidget);
  });
}

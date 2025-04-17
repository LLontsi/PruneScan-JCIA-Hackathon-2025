import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prune_scan/main.dart';

void main() {
  testWidgets('App initializes properly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PruneScanApp());

    // Verify that the splash screen is shown
    expect(find.text('PruneScan'), findsOneWidget);
  });
}
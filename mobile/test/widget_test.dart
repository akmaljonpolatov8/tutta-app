import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tutta/app/app.dart';

void main() {
  testWidgets('TuttaApp builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const TuttaApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('SplashPage shows app name', (WidgetTester tester) async {
    await tester.pumpWidget(const TuttaApp());
    await tester.pump();
    expect(find.text('Tutta'), findsOneWidget);
  });
}

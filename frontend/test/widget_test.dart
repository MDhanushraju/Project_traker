// Basic Flutter widget test for the app.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:projecttraker/app/app.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // App should build; we may land on login or dashboard depending on auth.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

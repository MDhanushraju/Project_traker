import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projecttraker/modules/auth/sign_up_page.dart';

void main() {
  testWidgets('SignUpPage shows Create Account', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpPage(),
      ),
    );
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}

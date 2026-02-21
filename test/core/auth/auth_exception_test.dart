import 'package:flutter_test/flutter_test.dart';
import 'package:projecttraker/core/auth/auth_exception.dart';

void main() {
  group('AuthException', () {
    test('stores message', () {
      final ex = AuthException('Invalid credentials');
      expect(ex.message, 'Invalid credentials');
    });

    test('toString returns message', () {
      final ex = AuthException('Email already exists');
      expect(ex.toString(), 'Email already exists');
    });

    test('implements Exception', () {
      expect(AuthException('test'), isA<Exception>());
    });
  });
}

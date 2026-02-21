import 'package:flutter_test/flutter_test.dart';
import 'package:projecttraker/core/constants/roles.dart';

void main() {
  group('AppRole', () {
    test('has all expected values', () {
      expect(AppRole.values, containsAll([AppRole.admin, AppRole.manager, AppRole.teamLeader, AppRole.member]));
    });

    test('admin has correct name', () {
      expect(AppRole.admin.name, 'admin');
    });

    test('member has correct name', () {
      expect(AppRole.member.name, 'member');
    });
  });

  group('AppRoleExtension.label', () {
    test('admin returns Admin', () {
      expect(AppRole.admin.label, 'Admin');
    });

    test('manager returns Manager', () {
      expect(AppRole.manager.label, 'Manager');
    });

    test('teamLeader returns Team Leader', () {
      expect(AppRole.teamLeader.label, 'Team Leader');
    });

    test('member returns Team Member', () {
      expect(AppRole.member.label, 'Team Member');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/user_model.dart';

void main() {
  group('UserModel Domain Tests', () {
    test('UserRole displayName returns human readable Indonesian job role', () {
      expect(UserRole.admin.displayName, equals('Administrator'));
      expect(UserRole.user.displayName, equals('Operator Gudang'));
    });

    test('UserModel correctly serializes to and from JSON including NIK and Role', () {
      final now = DateTime(2026, 10, 18, 12, 0);
      final admin = UserModel(
        id: 'usr-001',
        nik: 'ADM-001',
        name: 'Pramudya Administrator',
        email: 'admin@gudangpro.com',
        phone: '08123456789',
        role: UserRole.admin,
        isActive: true,
        avatarUrl: '',
        createdAt: now,
      );

      expect(admin.isAdmin, isTrue);
      expect(admin.isUser, isFalse);
      expect(admin.nik, equals('ADM-001'));

      final json = admin.toJson();
      expect(json['nik'], equals('ADM-001'));
      expect(json['role'], equals('admin'));

      final parsed = UserModel.fromJson(json);
      expect(parsed.id, equals(admin.id));
      expect(parsed.nik, equals(admin.nik));
      expect(parsed.role, equals(UserRole.admin));
      expect(parsed.name, equals(admin.name));
      expect(parsed.phone, equals(admin.phone));
      expect(parsed.isActive, equals(admin.isActive));
      expect(parsed.avatarUrl, equals(admin.avatarUrl));
      expect(parsed.createdAt, equals(admin.createdAt));
    });

    test('UserModel copyWith modifies fields cleanly', () {
      final user = UserModel(
        id: 'usr-002',
        nik: 'STF-042',
        name: 'Budi Santoso',
        email: 'operator@gudangpro.com',
        phone: '08987654321',
        role: UserRole.user,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final updated = user.copyWith(
        name: 'Budi Santoso S.T.',
        phone: '08111222333',
        isActive: false,
      );

      expect(updated.name, equals('Budi Santoso S.T.'));
      expect(updated.phone, equals('08111222333'));
      expect(updated.isActive, isFalse);
      expect(updated.nik, equals('STF-042'));
      expect(updated.role, equals(UserRole.user));
    });
  });
}

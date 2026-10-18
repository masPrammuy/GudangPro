import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/auth_repository.dart';
import 'package:mobile/features/auth/data/user_model.dart';
import 'package:mobile/features/auth/providers/auth_providers.dart';

void main() {
  group('AuthRepository Unit Tests', () {
    late AuthRepository repo;

    setUp(() {
      repo = AuthRepository();
    });

    test('Login with valid default admin credentials succeeds', () async {
      final user = await repo.login('admin@gudangpro.com', 'admin123');
      expect(user, isNotNull);
      expect(user!.isAdmin, isTrue);
      expect(user.nik, equals('ADM-001'));
      expect(user.name, equals('Pramudya Administrator'));
      expect(user.role, equals(UserRole.admin));
    });

    test('Login with valid default operator credentials succeeds', () async {
      final user = await repo.login('operator@gudangpro.com', 'user123');
      expect(user, isNotNull);
      expect(user!.isUser, isTrue);
      expect(user.nik, equals('STF-042'));
      expect(user.name, equals('Budi Santoso (Staff Gudang)'));
      expect(user.role, equals(UserRole.user));
    });

    test('Login with invalid credentials returns null', () async {
      final wrongPassword = await repo.login('admin@gudangpro.com', 'wrongpassword');
      expect(wrongPassword, isNull);

      final wrongEmail = await repo.login('nonexistent@gudangpro.com', 'admin123');
      expect(wrongEmail, isNull);
    });

    test('Admin can create a new user with custom NIK', () async {
      final newUser = UserModel(
        id: 'usr-new-003',
        nik: 'STF-088',
        name: 'Ahmad Fauzi',
        email: 'ahmad@gudangpro.com',
        phone: '081299887766',
        role: UserRole.user,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final created = await repo.createUser(newUser, 'ahmad123');
      expect(created.id, equals('usr-new-003'));
      expect(created.nik, equals('STF-088'));

      final allUsers = await repo.getAllUsers();
      expect(allUsers.any((u) => u.nik == 'STF-088'), isTrue);

      final loggedIn = await repo.login('ahmad@gudangpro.com', 'ahmad123');
      expect(loggedIn, isNotNull);
      expect(loggedIn!.name, equals('Ahmad Fauzi'));
      expect(loggedIn.nik, equals('STF-088'));
    });

    test('Updating user profile persists in user list', () async {
      final user = await repo.login('operator@gudangpro.com', 'user123');
      expect(user, isNotNull);

      final updated = user!.copyWith(
        name: 'Budi Santoso Senior',
        phone: '0877112233',
      );
      await repo.updateUserProfile(updated);

      final reloaded = await repo.login('operator@gudangpro.com', 'user123');
      expect(reloaded, isNotNull);
      expect(reloaded!.name, equals('Budi Santoso Senior'));
      expect(reloaded.phone, equals('0877112233'));

      final allUsers = await repo.getAllUsers();
      final target = allUsers.firstWhere((u) => u.id == 'user-stf-042');
      expect(target.name, equals('Budi Santoso Senior'));
    });

    test('Deactivated user cannot login', () async {
      await repo.toggleUserStatus('user-stf-042', false);
      final attempt = await repo.login('operator@gudangpro.com', 'user123');
      expect(attempt, isNull);

      // Re-activating enables login again
      await repo.toggleUserStatus('user-stf-042', true);
      final reattempt = await repo.login('operator@gudangpro.com', 'user123');
      expect(reattempt, isNotNull);
    });

    test('toggleUserStatus throws exception if user not found', () async {
      expect(
        () => repo.toggleUserStatus('nonexistent-id', false),
        throwsA(isA<Exception>()),
      );
    });

    test('updatePassword allows login with new password', () async {
      await repo.updatePassword('operator@gudangpro.com', 'newpass456');

      final oldPassAttempt = await repo.login('operator@gudangpro.com', 'user123');
      expect(oldPassAttempt, isNull);

      final newPassAttempt = await repo.login('operator@gudangpro.com', 'newpass456');
      expect(newPassAttempt, isNotNull);
      expect(newPassAttempt!.email, equals('operator@gudangpro.com'));
    });

    test('watchUsers stream emits current and updated users', () async {
      final initialUsers = await repo.watchUsers().first;
      expect(initialUsers.length, equals(2));

      final expectation = expectLater(
        repo.watchUsers(),
        emitsThrough(predicate<List<UserModel>>((list) => list.length == 3)),
      );

      final newUser = UserModel(
        id: 'usr-stream-01',
        nik: 'STF-099',
        name: 'Siti Aminah',
        email: 'siti@gudangpro.com',
        phone: '081234567800',
        role: UserRole.user,
        isActive: true,
        createdAt: DateTime.now(),
      );
      await repo.createUser(newUser, 'siti123');

      await expectation;
    });
  });

  group('Auth Riverpod Providers Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial currentUserProvider is null', () {
      final currentUser = container.read(currentUserProvider);
      expect(currentUser, isNull);
    });

    test('CurrentUserNotifier login updates currentUserProvider state', () async {
      final success = await container
          .read(currentUserProvider.notifier)
          .login('admin@gudangpro.com', 'admin123');

      expect(success, isTrue);
      final user = container.read(currentUserProvider);
      expect(user, isNotNull);
      expect(user!.isAdmin, isTrue);
      expect(user.nik, equals('ADM-001'));
    });

    test('CurrentUserNotifier login with wrong credentials returns false and keeps state null', () async {
      final success = await container
          .read(currentUserProvider.notifier)
          .login('admin@gudangpro.com', 'wrongpassword');

      expect(success, isFalse);
      expect(container.read(currentUserProvider), isNull);
    });

    test('CurrentUserNotifier logout resets currentUserProvider state to null', () async {
      await container
          .read(currentUserProvider.notifier)
          .login('admin@gudangpro.com', 'admin123');
      expect(container.read(currentUserProvider), isNotNull);

      container.read(currentUserProvider.notifier).logout();
      expect(container.read(currentUserProvider), isNull);
    });

    test('CurrentUserNotifier updateCurrentProfile updates current session state', () async {
      await container
          .read(currentUserProvider.notifier)
          .login('operator@gudangpro.com', 'user123');

      final current = container.read(currentUserProvider);
      expect(current, isNotNull);

      final updated = current!.copyWith(name: 'Budi Santoso Manager');
      await container.read(currentUserProvider.notifier).updateCurrentProfile(updated);

      final stateAfter = container.read(currentUserProvider);
      expect(stateAfter, isNotNull);
      expect(stateAfter!.name, equals('Budi Santoso Manager'));
    });

    test('userListProvider emits seed users list', () async {
      final userListAsync = container.read(userListProvider);
      expect(userListAsync, isA<AsyncValue<List<UserModel>>>());

      final users = await container.read(userListProvider.future);
      expect(users.length, equals(2));
      expect(users.any((u) => u.nik == 'ADM-001'), isTrue);
      expect(users.any((u) => u.nik == 'STF-042'), isTrue);
    });
  });
}

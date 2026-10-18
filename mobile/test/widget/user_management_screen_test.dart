import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/auth_repository.dart';
import 'package:mobile/features/auth/data/user_model.dart';
import 'package:mobile/features/auth/presentation/add_user_dialog.dart';
import 'package:mobile/features/auth/presentation/user_management_screen.dart';
import 'package:mobile/features/auth/providers/auth_providers.dart';
import 'package:mobile/features/profile/presentation/edit_profile_dialog.dart';

class FakeCurrentUserNotifier extends CurrentUserNotifier {
  FakeCurrentUserNotifier(super.repo, [UserModel? initialUser]) {
    state = initialUser;
  }
}

void main() {
  final testAdminUser = UserModel(
    id: 'user-adm-001',
    nik: 'ADM-001',
    name: 'Pramudya Administrator',
    email: 'admin@gudangpro.com',
    phone: '081234567890',
    role: UserRole.admin,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
  );

  group('UserManagementScreen & AddUserDialog Widget Tests', () {
    testWidgets(
        'UserManagementScreen renders list of users with NIK, name, role badge, and active status',
        (tester) async {
      final repo = AuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
            currentUserProvider.overrideWith(
              (ref) => FakeCurrentUserNotifier(repo, testAdminUser),
            ),
          ],
          child: const MaterialApp(
            home: UserManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('Manajemen Pengguna'), findsOneWidget);

      // Verify Admin user card info
      expect(find.text('Pramudya Administrator'), findsOneWidget);
      expect(find.text('ADM-001'), findsOneWidget);
      expect(find.text('admin@gudangpro.com'), findsOneWidget);
      expect(find.text('Administrator'), findsWidgets);
      expect(find.text('Aktif'), findsWidgets);
      expect(find.text('Saya'), findsOneWidget);

      // Verify Operator user card info
      expect(find.text('Budi Santoso (Staff Gudang)'), findsOneWidget);
      expect(find.text('STF-042'), findsOneWidget);
      expect(find.text('operator@gudangpro.com'), findsOneWidget);
      expect(find.text('Operator Gudang'), findsWidgets);

      // Verify Add User button/FAB
      expect(find.text('Tambah Akun User'), findsOneWidget);
    });

    testWidgets(
        'Tapping Tambah Akun User opens AddUserDialog with NIK, Name, Email, Password, and Role fields',
        (tester) async {
      final repo = AuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
            currentUserProvider.overrideWith(
              (ref) => FakeCurrentUserNotifier(repo, testAdminUser),
            ),
          ],
          child: const MaterialApp(
            home: UserManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Tambah Akun User
      await tester.tap(find.text('Tambah Akun User'));
      await tester.pumpAndSettle();

      // Verify Dialog is opened
      expect(find.byType(AddUserDialog), findsOneWidget);
      expect(find.text('Tambah Akun Pengguna'), findsOneWidget);

      // Verify fields exist
      expect(find.byKey(const Key('add_nik_field')), findsOneWidget);
      expect(find.byKey(const Key('add_name_field')), findsOneWidget);
      expect(find.byKey(const Key('add_email_field')), findsOneWidget);
      expect(find.byKey(const Key('add_password_field')), findsOneWidget);
      expect(find.byKey(const Key('add_role_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('submit_user_button')), findsOneWidget);
    });

    testWidgets(
        'Submitting AddUserDialog registers a new user with custom NIK into the repository',
        (tester) async {
      final repo = AuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
            currentUserProvider.overrideWith(
              (ref) => FakeCurrentUserNotifier(repo, testAdminUser),
            ),
          ],
          child: const MaterialApp(
            home: UserManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open Dialog
      await tester.tap(find.text('Tambah Akun User'));
      await tester.pumpAndSettle();

      // Enter form values
      await tester.enterText(
          find.byKey(const Key('add_nik_field')), 'STF-099');
      await tester.enterText(
          find.byKey(const Key('add_name_field')), 'Siti Aminah');
      await tester.enterText(
          find.byKey(const Key('add_email_field')), 'siti@gudangpro.com');
      await tester.enterText(
          find.byKey(const Key('add_phone_field')), '081298765432');
      await tester.enterText(
          find.byKey(const Key('add_password_field')), 'password123');
      await tester.pump();

      // Tap submit button
      await tester.tap(find.byKey(const Key('submit_user_button')));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.byType(AddUserDialog), findsNothing);

      // Verify user in repository
      final users = await repo.getAllUsers();
      final added = users.firstWhere((u) => u.nik == 'STF-099');
      expect(added.name, equals('Siti Aminah'));
      expect(added.email, equals('siti@gudangpro.com'));
      expect(added.phone, equals('081298765432'));
      expect(added.role, equals(UserRole.user));
      expect(added.isActive, isTrue);

      // Verify screen updated
      expect(find.text('Siti Aminah'), findsOneWidget);
      expect(find.text('STF-099'), findsOneWidget);
      expect(find.text('siti@gudangpro.com'), findsOneWidget);

      // Verify success snackbar
      expect(find.text('Akun pengguna berhasil ditambahkan'), findsOneWidget);
    });

    testWidgets(
        'Tapping edit on a user card opens EditProfileDialog with isEditingOther: true allowing full edit',
        (tester) async {
      final repo = AuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
            currentUserProvider.overrideWith(
              (ref) => FakeCurrentUserNotifier(repo, testAdminUser),
            ),
          ],
          child: const MaterialApp(
            home: UserManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find edit button for operator user (STF-042)
      final editBtn = find.byKey(const Key('edit_user_button_STF-042'));
      expect(editBtn, findsOneWidget);

      // Tap edit button
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      // Verify EditProfileDialog is opened with isEditingOther: true
      expect(find.byType(EditProfileDialog), findsOneWidget);
      expect(find.text('Edit Pengguna'), findsOneWidget);

      // Check fields are editable because isEditingOther == true & admin
      final nikField = tester.widget<TextField>(find.descendant(
          of: find.byKey(const Key('edit_nik_field')),
          matching: find.byType(TextField)));
      final emailField = tester.widget<TextField>(find.descendant(
          of: find.byKey(const Key('edit_email_field')),
          matching: find.byType(TextField)));

      expect(nikField.readOnly, isFalse);
      expect(emailField.readOnly, isFalse);

      // Verify Role dropdown & Status switch are present
      expect(find.byKey(const Key('edit_role_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('edit_status_switch')), findsOneWidget);
    });
  });
}

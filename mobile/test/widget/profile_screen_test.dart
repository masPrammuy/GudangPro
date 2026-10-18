import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/auth_repository.dart';
import 'package:mobile/features/auth/data/user_model.dart';
import 'package:mobile/features/auth/providers/auth_providers.dart';
import 'package:mobile/features/profile/presentation/edit_profile_dialog.dart';
import 'package:mobile/features/profile/presentation/profile_screen.dart';

class FakeCurrentUserNotifier extends CurrentUserNotifier {
  FakeCurrentUserNotifier(super.repo, [UserModel? initialUser]) {
    state = initialUser;
  }
}

void main() {
  final testNormalUser = UserModel(
    id: 'user-stf-042',
    nik: 'STF-042',
    name: 'Budi Santoso',
    email: 'operator@gudangpro.com',
    phone: '089876543210',
    role: UserRole.user,
    isActive: true,
    createdAt: DateTime(2026, 2, 1),
  );

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

  group('ProfileScreen & EditProfileDialog Widget Tests', () {
    testWidgets(
        'ProfileScreen renders user NIK, name, role badge, email, phone, status, and edit button',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => FakeCurrentUserNotifier(
                ref.watch(authRepositoryProvider),
                testNormalUser,
              ),
            ),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      // Verify user details
      expect(find.text('Budi Santoso'), findsWidgets);
      expect(find.text('STF-042'), findsOneWidget);
      expect(find.text('operator@gudangpro.com'), findsOneWidget);
      expect(find.text('089876543210'), findsOneWidget);
      expect(find.text('Operator Gudang'), findsWidgets);
      expect(find.text('Aktif'), findsOneWidget);

      // Verify initials avatar
      expect(find.text('BS'), findsOneWidget);

      // Verify Edit button
      expect(find.text('Edit Profil Saya'), findsOneWidget);
      expect(find.byKey(const Key('edit_profile_button')), findsOneWidget);

      // Verify Logout icon button
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets(
        'Tapping Edit Profil Saya as a normal user opens dialog with NIK and Email in read-only / locked mode',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => FakeCurrentUserNotifier(
                ref.watch(authRepositoryProvider),
                testNormalUser,
              ),
            ),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      // Tap Edit Profil Saya
      await tester.tap(find.byKey(const Key('edit_profile_button')));
      await tester.pumpAndSettle();

      // Verify dialog is opened
      expect(find.byType(EditProfileDialog), findsOneWidget);
      expect(find.text('Edit Profil'), findsOneWidget);

      // Find TextField widgets
      final nikField = tester.widget<TextField>(find.descendant(
          of: find.byKey(const Key('edit_nik_field')),
          matching: find.byType(TextField)));
      final emailField = tester.widget<TextField>(find.descendant(
          of: find.byKey(const Key('edit_email_field')),
          matching: find.byType(TextField)));
      final nameField = tester.widget<TextField>(find.descendant(
          of: find.byKey(const Key('edit_name_field')),
          matching: find.byType(TextField)));
      final phoneField = tester.widget<TextField>(find.descendant(
          of: find.byKey(const Key('edit_phone_field')),
          matching: find.byType(TextField)));

      // NIK and Email must be read-only for normal user editing themselves
      expect(nikField.readOnly, isTrue);
      expect(emailField.readOnly, isTrue);

      // Name and Phone must NOT be read-only
      expect(nameField.readOnly, isFalse);
      expect(phoneField.readOnly, isFalse);

      // Verify locked icons are shown in decoration
      expect(find.byIcon(Icons.lock), findsNWidgets(2));

      // Role and Status controls should not be visible for self-edit
      expect(find.byKey(const Key('edit_role_dropdown')), findsNothing);
      expect(find.byKey(const Key('edit_status_switch')), findsNothing);
    });

    testWidgets(
        'Updating name and phone in the dialog saves and updates the state',
        (tester) async {
      UserModel? updatedUserState;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => FakeCurrentUserNotifier(
                ref.watch(authRepositoryProvider),
                testNormalUser,
              ),
            ),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                ref.listen<UserModel?>(currentUserProvider, (_, next) {
                  updatedUserState = next;
                });
                return const ProfileScreen();
              },
            ),
          ),
        ),
      );

      // Tap Edit Profil Saya
      await tester.tap(find.byKey(const Key('edit_profile_button')));
      await tester.pumpAndSettle();

      // Enter updated name and phone
      await tester.enterText(
          find.byKey(const Key('edit_name_field')), 'Budi Santoso Updated');
      await tester.enterText(
          find.byKey(const Key('edit_phone_field')), '081199998888');
      await tester.pump();

      // Tap save button
      await tester.tap(find.byKey(const Key('save_profile_button')));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(EditProfileDialog), findsNothing);

      // Verify state was updated
      expect(updatedUserState, isNotNull);
      expect(updatedUserState!.name, equals('Budi Santoso Updated'));
      expect(updatedUserState!.phone, equals('081199998888'));
      expect(updatedUserState!.nik, equals('STF-042'));
      expect(updatedUserState!.email, equals('operator@gudangpro.com'));

      // Verify ProfileScreen displays updated name
      expect(find.text('Budi Santoso Updated'), findsWidgets);
      expect(find.text('081199998888'), findsOneWidget);

      // Verify success snackbar
      expect(find.text('Profil berhasil diperbarui'), findsOneWidget);
    });

    testWidgets('Tapping Logout triggers currentUserProvider.notifier.logout()',
        (tester) async {
      UserModel? currentUser = testNormalUser;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => FakeCurrentUserNotifier(
                ref.watch(authRepositoryProvider),
                testNormalUser,
              ),
            ),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                ref.listen<UserModel?>(currentUserProvider, (_, next) {
                  currentUser = next;
                });
                return const ProfileScreen();
              },
            ),
          ),
        ),
      );

      expect(currentUser, isNotNull);

      // Tap logout icon button
      await tester.tap(find.byKey(const Key('profile_logout_button')));
      await tester.pumpAndSettle();

      // Verify currentUser is now null
      expect(currentUser, isNull);
    });

    testWidgets(
        'Admin editing another user (isEditingOther == true) allows editing NIK, Email, Role, and Status',
        (tester) async {
      final repo = AuthRepository();
      UserModel? savedUser;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
            currentUserProvider.overrideWith(
              (ref) => FakeCurrentUserNotifier(
                repo,
                testAdminUser,
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => EditProfileDialog(
                        targetUser: testNormalUser,
                        isEditingOther: true,
                        onSaved: (user) {
                          savedUser = user;
                        },
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Check fields are editable (not readOnly)
      final nikField = tester.widget<TextField>(find.descendant(
          of: find.byKey(const Key('edit_nik_field')),
          matching: find.byType(TextField)));
      final emailField = tester.widget<TextField>(find.descendant(
          of: find.byKey(const Key('edit_email_field')),
          matching: find.byType(TextField)));
      expect(nikField.readOnly, isFalse);
      expect(emailField.readOnly, isFalse);

      // Verify Role dropdown and Status switch exist
      expect(find.byKey(const Key('edit_role_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('edit_status_switch')), findsOneWidget);

      // Edit NIK and toggle Active switch
      await tester.enterText(
          find.byKey(const Key('edit_nik_field')), 'STF-999');
      await tester.enterText(
          find.byKey(const Key('edit_email_field')), 'newoperator@gudangpro.com');
      await tester.ensureVisible(find.byKey(const Key('edit_status_switch')));
      await tester.tap(find.byKey(const Key('edit_status_switch')));
      await tester.pump();

      // Tap Save
      await tester.tap(find.byKey(const Key('save_profile_button')));
      await tester.pumpAndSettle();

      // Verify savedUser received updated data
      expect(savedUser, isNotNull);
      expect(savedUser!.nik, equals('STF-999'));
      expect(savedUser!.email, equals('newoperator@gudangpro.com'));
      expect(savedUser!.isActive, isFalse);
    });
  });
}

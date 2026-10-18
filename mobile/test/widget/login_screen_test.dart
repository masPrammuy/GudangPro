import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/user_model.dart';
import 'package:mobile/features/auth/presentation/login_screen.dart';
import 'package:mobile/features/auth/providers/auth_providers.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen renders logo, form fields, and quick fill buttons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify logo / branding
      expect(find.text('GudangPro Apparel'), findsOneWidget);
      expect(find.text('Masuk ke Sistem WMS'), findsOneWidget);
      expect(find.byIcon(Icons.warehouse_rounded), findsWidgets);

      // Verify form fields by Key
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);

      // Verify buttons
      expect(find.text('Masuk Sekarang'), findsOneWidget);
      expect(find.text('Quick Fill Admin'), findsOneWidget);
      expect(find.text('Quick Fill Operator'), findsOneWidget);
    });

    testWidgets('Tapping Quick Fill Admin populates admin email and password and triggers login', (tester) async {
      UserModel? loggedInUser;
      bool successCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                ref.listen<UserModel?>(currentUserProvider, (_, next) {
                  loggedInUser = next;
                });
                return LoginScreen(
                  onLoginSuccess: () {
                    successCalled = true;
                  },
                );
              },
            ),
          ),
        ),
      );

      // Tap Quick Fill Admin
      await tester.tap(find.text('Quick Fill Admin'));
      await tester.pump();

      // Verify fields are populated
      expect(find.text('admin@gudangpro.com'), findsOneWidget);
      expect(find.text('admin123'), findsOneWidget);

      // Tap Masuk Sekarang
      await tester.tap(find.text('Masuk Sekarang'));
      await tester.pumpAndSettle();

      // Verify login succeeded
      expect(loggedInUser, isNotNull);
      expect(loggedInUser!.email, equals('admin@gudangpro.com'));
      expect(loggedInUser!.isAdmin, isTrue);
      expect(successCalled, isTrue);
    });

    testWidgets('Tapping Quick Fill Operator populates operator credentials', (tester) async {
      UserModel? loggedInUser;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                ref.listen<UserModel?>(currentUserProvider, (_, next) {
                  loggedInUser = next;
                });
                return const LoginScreen();
              },
            ),
          ),
        ),
      );

      // Tap Quick Fill Operator
      await tester.tap(find.text('Quick Fill Operator'));
      await tester.pump();

      // Verify fields populated
      expect(find.text('operator@gudangpro.com'), findsOneWidget);
      expect(find.text('user123'), findsOneWidget);

      // Tap Masuk Sekarang
      await tester.tap(find.text('Masuk Sekarang'));
      await tester.pumpAndSettle();

      // Verify login succeeded
      expect(loggedInUser, isNotNull);
      expect(loggedInUser!.email, equals('operator@gudangpro.com'));
      expect(loggedInUser!.isUser, isTrue);
    });

    testWidgets('Validation error appears if fields are empty upon tapping login', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Tap submit with empty fields
      await tester.tap(find.text('Masuk Sekarang'));
      await tester.pumpAndSettle();

      // Expect validation messages
      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('Shows error banner when login fails with invalid credentials', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Enter invalid credentials
      await tester.enterText(find.byKey(const Key('email_field')), 'salah@gudangpro.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'wrongpass');
      await tester.pump();

      // Tap Masuk Sekarang
      await tester.tap(find.text('Masuk Sekarang'));
      await tester.pumpAndSettle();

      // Verify error banner is displayed
      expect(find.text('Email atau password salah. Silakan coba lagi.'), findsOneWidget);
      expect(find.byKey(const Key('login_error_banner')), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/features/auth/data/auth_repository.dart';
import 'package:mobile/features/auth/data/user_model.dart';
import 'package:mobile/features/auth/presentation/login_screen.dart';
import 'package:mobile/features/auth/providers/auth_providers.dart';
import 'package:mobile/features/inventory/data/item_model.dart';
import 'package:mobile/features/inventory/providers/inventory_providers.dart';

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

  final mockItems = [
    ItemModel(
      id: 'item-1',
      sku: 'KAN-CMB-01',
      name: 'Kain Katun Combed 30s',
      category: 'Kain & Bahan Baku',
      qty: 45,
      unit: 'Roll',
      minStock: 15,
      location: 'Rak A-01',
      zone: 'A',
      status: 'Tersedia',
    ),
  ];

  group('GudangProApp Auth Routing & Role-Based Navigation Tests', () {
    testWidgets('GudangProApp displays LoginScreen when unauthenticated (currentUserProvider is null)', (tester) async {
      final repo = AuthRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
            inventoryListProvider.overrideWith((ref) => AsyncValue.data(mockItems)),
            currentUserProvider.overrideWith(
              (ref) => FakeCurrentUserNotifier(repo, null),
            ),
          ],
          child: const GudangProApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify LoginScreen is displayed
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('GudangPro Apparel'), findsOneWidget);
      expect(find.text('Masuk ke Sistem WMS'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Masuk Sekarang'), findsOneWidget);

      // Verify operational navigation destinations are not shown
      expect(find.text('Dashboard'), findsNothing);
      expect(find.text('Pengguna'), findsNothing);
    });

    testWidgets('GudangProApp displays Admin tabs (Dashboard, Pengguna) when authenticated as Admin', (tester) async {
      final repo = AuthRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
            inventoryListProvider.overrideWith((ref) => AsyncValue.data(mockItems)),
            currentUserProvider.overrideWith(
              (ref) => FakeCurrentUserNotifier(repo, testAdminUser),
            ),
          ],
          child: const GudangProApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify LoginScreen is NOT shown
      expect(find.byType(LoginScreen), findsNothing);

      // Verify all 7 Admin destinations are rendered
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Stok'), findsOneWidget);
      expect(find.text('Bahan Masuk'), findsOneWidget);
      expect(find.text('Kirim Baju'), findsOneWidget);
      expect(find.text('Opname'), findsOneWidget);
      expect(find.text('Pengguna'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Initial tab for Admin is Dashboard
      expect(find.text('Dashboard Analitik Gudang'), findsOneWidget);

      // Navigate to Pengguna tab
      await tester.tap(find.text('Pengguna'));
      await tester.pumpAndSettle();
      expect(find.text('Manajemen Pengguna'), findsOneWidget);

      // Navigate to Stok tab
      await tester.tap(find.text('Stok'));
      await tester.pumpAndSettle();
      expect(find.text('Stok Master Garmen'), findsOneWidget);

      // Navigate to Profil tab
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Profil Pengguna'), findsOneWidget);
    });

    testWidgets('GudangProApp displays User tabs and HIDES Admin tabs when authenticated as User', (tester) async {
      final repo = AuthRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
            inventoryListProvider.overrideWith((ref) => AsyncValue.data(mockItems)),
            currentUserProvider.overrideWith(
              (ref) => FakeCurrentUserNotifier(repo, testNormalUser),
            ),
          ],
          child: const GudangProApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify LoginScreen is NOT shown
      expect(find.byType(LoginScreen), findsNothing);

      // Verify Admin-only destinations are HIDDEN
      expect(find.text('Dashboard'), findsNothing);
      expect(find.text('Pengguna'), findsNothing);

      // Verify 5 User destinations are rendered
      expect(find.text('Stok'), findsOneWidget);
      expect(find.text('Bahan Masuk'), findsOneWidget);
      expect(find.text('Kirim Baju'), findsOneWidget);
      expect(find.text('Opname'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Initial tab for User is Stok
      expect(find.text('Stok Master Garmen'), findsOneWidget);

      // Navigate across operational tabs
      await tester.tap(find.text('Bahan Masuk'));
      await tester.pumpAndSettle();
      expect(find.text('Penerimaan Bahan Masuk (PO)'), findsOneWidget);

      await tester.tap(find.text('Kirim Baju'));
      await tester.pumpAndSettle();
      expect(find.text('Surat Jalan Pengiriman (DO)'), findsOneWidget);

      await tester.tap(find.text('Opname'));
      await tester.pumpAndSettle();
      expect(find.text('Stock Opname & Audit Fisik'), findsOneWidget);

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Profil Pengguna'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsWidgets);
    });

    testWidgets('MainNavigationScaffold bounds check resets index if role change reduces tab count', (tester) async {
      final repo = AuthRepository();
      final notifier = FakeCurrentUserNotifier(repo, testAdminUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
            inventoryListProvider.overrideWith((ref) => AsyncValue.data(mockItems)),
            currentUserProvider.overrideWith((ref) => notifier),
          ],
          child: const GudangProApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap index 6: Profil (Admin has 7 tabs: 0 to 6)
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Profil Pengguna'), findsOneWidget);

      // Now switch current user to Normal User (5 tabs: 0 to 4)
      notifier.state = testNormalUser;
      await tester.pumpAndSettle();

      // Safe index bound should reset to 0 (Stok) without out-of-bounds crash
      expect(find.text('Stok Master Garmen'), findsOneWidget);
    });
  });
}

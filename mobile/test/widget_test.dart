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
  testWidgets('GudangProApp displays Workshop Telemetry Dashboard as first tab for Admin and User', (tester) async {
    final user = UserModel(
      id: 'usr-1',
      nik: 'STF-042',
      name: 'Budi Santoso',
      email: 'operator@gudangpro.com',
      phone: '08123',
      role: UserRole.user,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith((ref) => CurrentUserNotifier(ref.watch(authRepositoryProvider))..state = user),
        ],
        child: const GudangProApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Denah & Kapasitas 4 Zona Workshop Konveksi Pakaian'), findsOneWidget);
    expect(find.text('Cek Stok Kain & Baju Jadi'), findsOneWidget);
    expect(find.text('Beranda'), findsWidgets);
  });

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

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('GudangPro Apparel'), findsOneWidget);
      expect(find.text('Masuk ke Sistem WMS'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Masuk Sekarang'), findsOneWidget);

      expect(find.text('Beranda'), findsNothing);
      expect(find.text('Pengguna'), findsNothing);
    });

    testWidgets('GudangProApp displays LoginScreen when currentUser is deactivated (isActive == false)', (tester) async {
      final repo = AuthRepository();
      final deactivatedUser = testNormalUser.copyWith(isActive: false);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
            inventoryListProvider.overrideWith((ref) => AsyncValue.data(mockItems)),
            currentUserProvider.overrideWith(
              (ref) => FakeCurrentUserNotifier(repo, deactivatedUser),
            ),
          ],
          child: const GudangProApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Masuk ke Sistem WMS'), findsOneWidget);
    });

    testWidgets('GudangProApp displays Admin tabs (Beranda, Grafik, Stok, ..., Pengguna, Profil) when authenticated as Admin', (tester) async {
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

      expect(find.byType(LoginScreen), findsNothing);

      // Verify all 8 Admin destinations are rendered
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Grafik'), findsOneWidget);
      expect(find.text('Stok'), findsOneWidget);
      expect(find.text('Bahan Masuk'), findsOneWidget);
      expect(find.text('Kirim Baju'), findsOneWidget);
      expect(find.text('Opname'), findsOneWidget);
      expect(find.text('Pengguna'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Initial tab for Admin is Beranda (Workshop Telemetry)
      expect(find.text('Denah & Kapasitas 4 Zona Workshop Konveksi Pakaian'), findsOneWidget);

      // Navigate to Grafik tab
      await tester.tap(find.text('Grafik'));
      await tester.pumpAndSettle();
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

      expect(find.byType(LoginScreen), findsNothing);

      // Verify Admin-only destinations are HIDDEN
      expect(find.text('Grafik'), findsNothing);
      expect(find.text('Pengguna'), findsNothing);

      // Verify 6 User destinations are rendered
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Stok'), findsOneWidget);
      expect(find.text('Bahan Masuk'), findsOneWidget);
      expect(find.text('Kirim Baju'), findsOneWidget);
      expect(find.text('Opname'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Initial tab for User is Beranda
      expect(find.text('Denah & Kapasitas 4 Zona Workshop Konveksi Pakaian'), findsOneWidget);

      // Navigate across operational tabs
      await tester.tap(find.text('Stok'));
      await tester.pumpAndSettle();
      expect(find.text('Stok Master Garmen'), findsOneWidget);

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

      // Tap index 7: Profil (Admin has 8 tabs: 0 to 7)
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Profil Pengguna'), findsOneWidget);

      // Now switch current user to Normal User (6 tabs: 0 to 5)
      notifier.state = testNormalUser;
      await tester.pumpAndSettle();

      // Safe index bound should reset to 0 (Beranda) without out-of-bounds crash
      expect(find.text('Denah & Kapasitas 4 Zona Workshop Konveksi Pakaian'), findsOneWidget);
    });

    testWidgets('Tapping "Lihat di Tabel ↓" in CriticalStockBanner navigates Admin to Inventory (Tab 2)', (tester) async {
      final repo = AuthRepository();
      final criticalItems = [
        ItemModel(
          id: 'item-crit-1',
          sku: 'RST-YKK-60',
          name: 'Resleting YKK 60cm',
          category: 'Aksesoris',
          qty: 2,
          unit: 'Pcs',
          minStock: 20,
          location: 'Rak B-02',
          zone: 'B',
          status: 'Menipis',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
            inventoryListProvider.overrideWith((ref) => AsyncValue.data(criticalItems)),
            currentUserProvider.overrideWith(
              (ref) => FakeCurrentUserNotifier(repo, testAdminUser),
            ),
          ],
          child: const GudangProApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure critical banner is shown with button
      final buttonFinder = find.text('Lihat di Tabel ↓');
      expect(buttonFinder, findsOneWidget);

      // Scroll into view and tap "Lihat di Tabel ↓"
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Admin should now be on InventoryScreen (Tab 2: Stok Master Garmen)
      expect(find.text('Stok Master Garmen'), findsOneWidget);
    });

    testWidgets('Tapping "Lihat di Tabel ↓" in CriticalStockBanner navigates User to Inventory (Tab 1)', (tester) async {
      final repo = AuthRepository();
      final criticalItems = [
        ItemModel(
          id: 'item-crit-1',
          sku: 'RST-YKK-60',
          name: 'Resleting YKK 60cm',
          category: 'Aksesoris',
          qty: 0,
          unit: 'Pcs',
          minStock: 20,
          location: 'Rak B-02',
          zone: 'B',
          status: 'Habis',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
            inventoryListProvider.overrideWith((ref) => AsyncValue.data(criticalItems)),
            currentUserProvider.overrideWith(
              (ref) => FakeCurrentUserNotifier(repo, testNormalUser),
            ),
          ],
          child: const GudangProApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure critical banner is shown with button
      final buttonFinder = find.text('Lihat di Tabel ↓');
      expect(buttonFinder, findsOneWidget);

      // Scroll into view and tap "Lihat di Tabel ↓"
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // User should now be on InventoryScreen (Tab 1: Stok Master Garmen)
      expect(find.text('Stok Master Garmen'), findsOneWidget);
    });
  });
}

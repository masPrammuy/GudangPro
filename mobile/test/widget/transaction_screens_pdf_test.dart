import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/user_model.dart';
import 'package:mobile/features/auth/providers/auth_providers.dart';
import 'package:mobile/features/inbound/presentation/inbound_screen.dart';
import 'package:mobile/features/inventory/data/item_model.dart';
import 'package:mobile/features/inventory/providers/inventory_providers.dart';
import 'package:mobile/features/outbound/presentation/outbound_screen.dart';

void main() {
  final mockItem = ItemModel(
    id: 'bju-ovs-blk',
    sku: 'BJU-OVS-BLK',
    name: 'Baju Kaos Polos Oversize',
    category: 'Baju Jadi',
    qty: 25,
    unit: 'Pcs',
    minStock: 10,
    location: 'Rak D-01',
    zone: 'D',
    status: 'Tersedia',
  );

  final mockUser = UserModel(
    id: 'adm',
    nik: 'ADM-001',
    name: 'Pramudya Administrator',
    email: 'admin@gudangpro.com',
    phone: '08123',
    role: UserRole.admin,
    createdAt: DateTime.now(),
  );

  testWidgets('InboundScreen renders Cetak Surat Masuk (PDF) action button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryListProvider.overrideWith((ref) => AsyncValue.data([mockItem])),
          currentUserProvider.overrideWith((ref) => CurrentUserNotifier(ref.watch(authRepositoryProvider))..state = mockUser),
        ],
        child: const MaterialApp(home: InboundScreen()),
      ),
    );

    expect(find.text('Cetak Surat Masuk (PDF)'), findsOneWidget);
  });

  testWidgets('OutboundScreen renders Cetak Surat Jalan (PDF) action button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryListProvider.overrideWith((ref) => AsyncValue.data([mockItem])),
          currentUserProvider.overrideWith((ref) => CurrentUserNotifier(ref.watch(authRepositoryProvider))..state = mockUser),
        ],
        child: const MaterialApp(home: OutboundScreen()),
      ),
    );

    expect(find.text('Cetak Surat Jalan (PDF)'), findsOneWidget);
  });
}

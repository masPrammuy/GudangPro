import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/features/inventory/data/item_model.dart';
import 'package:mobile/features/inventory/providers/inventory_providers.dart';

void main() {
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

  testWidgets('GudangProApp integrates 4 operational modules with adaptive navigation', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryListProvider.overrideWith((ref) => AsyncValue.data(mockItems)),
        ],
        child: const GudangProApp(),
      ),
    );

    // Initial tab: Stok
    expect(find.text('Stok Master Garmen'), findsOneWidget);

    // Navigate to Bahan Masuk
    await tester.tap(find.text('Bahan Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Penerimaan Bahan Masuk (PO)'), findsOneWidget);

    // Navigate to Kirim Baju
    await tester.tap(find.text('Kirim Baju'));
    await tester.pumpAndSettle();
    expect(find.text('Surat Jalan Pengiriman (DO)'), findsOneWidget);

    // Navigate to Opname
    await tester.tap(find.text('Opname'));
    await tester.pumpAndSettle();
    expect(find.text('Stock Opname & Audit Fisik'), findsOneWidget);
  });
}

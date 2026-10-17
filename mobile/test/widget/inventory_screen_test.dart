import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/inventory/data/item_model.dart';
import 'package:mobile/features/inventory/presentation/inventory_screen.dart';
import 'package:mobile/features/inventory/providers/inventory_providers.dart';

void main() {
  testWidgets('InventoryScreen renders item cards and zone filters', (tester) async {
    final mockItems = [
      ItemModel(
        id: '1',
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryListProvider.overrideWith((ref) => AsyncValue.data(mockItems)),
        ],
        child: const MaterialApp(
          home: InventoryScreen(),
        ),
      ),
    );

    expect(find.text('KAN-CMB-01'), findsOneWidget);
    expect(find.text('Kain Katun Combed 30s'), findsOneWidget);
    expect(find.text('Zona A'), findsWidgets);
  });
}

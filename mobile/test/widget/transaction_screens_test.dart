import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/inbound/presentation/inbound_screen.dart';
import 'package:mobile/features/outbound/presentation/outbound_screen.dart';
import 'package:mobile/features/audit/presentation/audit_screen.dart';
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
    ItemModel(
      id: 'item-2',
      sku: 'BJU-OVR-BLK',
      name: 'Kaos Polos Oversize Hitam (L)',
      category: 'Baju Jadi (Siap Kirim)',
      qty: 5,
      unit: 'Pcs',
      minStock: 20,
      location: 'Rak D-03',
      zone: 'D',
      status: '⚠️ Stok Minimum!',
    ),
  ];

  testWidgets('InboundScreen renders PO transaction form', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryListProvider.overrideWith((ref) => AsyncValue.data(mockItems)),
        ],
        child: const MaterialApp(home: InboundScreen()),
      ),
    );
    expect(find.text('Penerimaan Bahan Masuk (PO)'), findsOneWidget);
    expect(find.text('Nomor Purchase Order (PO)'), findsOneWidget);

    final submitButton = find.text('Catat Bahan Masuk');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();
    expect(find.text('Bahan masuk PO-TX-2026-001 berhasil dicatat!'), findsOneWidget);
  });

  testWidgets('OutboundScreen validates anti-overshipping guard', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryListProvider.overrideWith((ref) => AsyncValue.data(mockItems)),
        ],
        child: const MaterialApp(home: OutboundScreen()),
      ),
    );
    expect(find.text('Surat Jalan Pengiriman (DO)'), findsOneWidget);
    expect(find.text('Nomor Surat Jalan (DO)'), findsOneWidget);

    // Enter quantity exceeding stock (available is 45, enter 100)
    final qtyField = find.widgetWithText(TextFormField, 'Kuantitas Kirim');
    await tester.enterText(qtyField, '100');
    await tester.pump();

    // Verify anti-overshipping error message is displayed
    expect(find.text('Stok tidak mencukupi! Tersedia hanya 45 Roll'), findsWidgets);

    // Enter valid quantity (10)
    await tester.enterText(qtyField, '10');
    await tester.pump();

    // Verify error message disappears and submit button is enabled
    expect(find.text('Stok tidak mencukupi! Tersedia hanya 45 Roll'), findsNothing);
    expect(find.text('Stok tersedia saat ini: 45 Roll'), findsOneWidget);
  });

  testWidgets('AuditScreen renders physical stock audit form and computes discrepancy', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryListProvider.overrideWith((ref) => AsyncValue.data(mockItems)),
        ],
        child: const MaterialApp(home: AuditScreen()),
      ),
    );
    expect(find.text('Stock Opname & Audit Fisik'), findsOneWidget);
    expect(find.text('Stok Fisik Aktual'), findsOneWidget);

    // Initial discrepancy is 0 (physical stock = 45, system stock = 45)
    expect(find.text('Selisih: 0 Roll (Sesuai)'), findsOneWidget);

    // Change physical stock to 40 (deficit of 5)
    final physicalField = find.widgetWithText(TextFormField, 'Stok Fisik Aktual');
    await tester.enterText(physicalField, '40');
    await tester.pump();
    expect(find.text('Selisih: -5 Roll (Kurang / Defisit)'), findsOneWidget);

    // Change physical stock to 50 (surplus of 5)
    await tester.enterText(physicalField, '50');
    await tester.pump();
    expect(find.text('Selisih: +5 Roll (Lebih / Surplus)'), findsOneWidget);

    // Test submit synchronization button
    final syncButton = find.text('Sinkronisasi Master Stok');
    await tester.ensureVisible(syncButton);
    await tester.tap(syncButton);
    await tester.pump();
    expect(find.text('Hasil audit fisik berhasil disinkronkan ke master stok!'), findsOneWidget);
  });
}

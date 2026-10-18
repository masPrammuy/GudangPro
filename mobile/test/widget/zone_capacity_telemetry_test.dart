import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/dashboard/presentation/widgets/critical_stock_banner.dart';
import 'package:mobile/features/dashboard/presentation/widgets/zone_capacity_telemetry.dart';
import 'package:mobile/features/inventory/data/item_model.dart';

void main() {
  final mockItems = [
    ItemModel(id: '1', sku: 'RST-YKK-60', name: 'Resleting Jaket YKK Metal 60cm', category: 'Aksesoris', qty: 0, unit: 'Pcs', minStock: 50, location: 'B-1', zone: 'B', status: '🚨 Stok Habis'),
    ItemModel(id: '2', sku: 'BJU-OVS-BLK', name: 'Kaos Polos Oversize Katun 24s', category: 'Baju Jadi', qty: 6, unit: 'Pcs', minStock: 30, location: 'D-1', zone: 'D', status: '⚠️ Stok Minimum!'),
  ];

  testWidgets('ZoneCapacityTelemetry renders 4 zones with capacity telemetry', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ZoneCapacityTelemetry())));
    expect(find.text('Denah & Kapasitas 4 Zona Workshop Konveksi Pakaian'), findsOneWidget);
    expect(find.textContaining('ZONA A'), findsOneWidget);
    expect(find.textContaining('ZONA B'), findsOneWidget);
    expect(find.textContaining('ZONA C'), findsOneWidget);
    expect(find.textContaining('ZONA D'), findsOneWidget);
  });

  testWidgets('CriticalStockBanner renders critical chips and triggers callback', (tester) async {
    bool callbackFired = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CriticalStockBanner(
            criticalItems: mockItems,
            onViewTablePressed: () {
              callbackFired = true;
            },
          ),
        ),
      ),
    );

    expect(find.textContaining('Peringatan: Stok Bahan / Baju Mencapai Batas Minimum!'), findsOneWidget);
    expect(find.text('2 Item Kritis'), findsOneWidget);
    expect(find.text('Lihat di Tabel ↓'), findsOneWidget);

    await tester.tap(find.text('Lihat di Tabel ↓'));
    await tester.pump();
    expect(callbackFired, isTrue);
  });
}

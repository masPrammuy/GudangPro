import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/dashboard/presentation/widgets/kpi_metric_cards.dart';
import 'package:mobile/features/dashboard/presentation/widgets/quick_steps_banner.dart';
import 'package:mobile/features/inventory/data/item_model.dart';

void main() {
  final mockItems = [
    ItemModel(id: '1', sku: 'SKU-1', name: 'Kain Katun', category: 'Kain', qty: 100, unit: 'Roll', minStock: 20, location: 'A-1', zone: 'A', status: 'Tersedia'),
    ItemModel(id: '2', sku: 'SKU-2', name: 'Resleting YKK', category: 'Aksesoris', qty: 0, unit: 'Pcs', minStock: 30, location: 'B-1', zone: 'B', status: '🚨 Stok Habis'),
    ItemModel(id: '3', sku: 'SKU-3', name: 'Kaos Polos', category: 'Baju Jadi', qty: 5, unit: 'Pcs', minStock: 20, location: 'D-1', zone: 'D', status: '⚠️ Stok Minimum!'),
  ];

  testWidgets('QuickStepsBanner renders 3 guide steps', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: QuickStepsBanner())));
    expect(find.text('Cek Stok Kain & Baju Jadi'), findsOneWidget);
    expect(find.text('Atur Batas Stok Minimum'), findsOneWidget);
    expect(find.text('Peringatan Otomatis Realtime'), findsOneWidget);
  });

  testWidgets('KpiMetricCards renders 4 telemetry cards matching reference image', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: KpiMetricCards(items: mockItems))));
    expect(find.text('Total Bahan & Baju (SKU)'), findsOneWidget);
    expect(find.text('Bahan/Kain Masuk (Hari Ini)'), findsOneWidget);
    expect(find.text('Baju Terkirim (Hari Ini)'), findsOneWidget);
    expect(find.text('Peringatan Stok Minimum'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // 2 items critical (1 habis + 1 minimum)
  });
}

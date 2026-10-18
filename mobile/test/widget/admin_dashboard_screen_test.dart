import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/dashboard/presentation/admin_dashboard_screen.dart';
import 'package:mobile/features/dashboard/presentation/widgets/audit_accuracy_gauge.dart';
import 'package:mobile/features/dashboard/presentation/widgets/inbound_outbound_chart.dart';
import 'package:mobile/features/dashboard/presentation/widgets/stock_health_chart.dart';
import 'package:mobile/features/dashboard/presentation/widgets/zone_distribution_chart.dart';
import 'package:mobile/features/inventory/data/item_model.dart';
import 'package:mobile/features/inventory/providers/inventory_providers.dart';

void main() {
  final sampleItems = [
    ItemModel(
      id: '1',
      sku: 'SKU-001',
      name: 'Kain Katun Combed 30s',
      category: 'Kain & Bahan Baku',
      qty: 100,
      unit: 'Roll',
      minStock: 20,
      location: 'Rak A-01',
      zone: 'A',
      status: 'Tersedia',
    ),
    ItemModel(
      id: '2',
      sku: 'SKU-002',
      name: 'Resleting YKK 60cm',
      category: 'Aksesoris Jahit',
      qty: 10,
      unit: 'Pcs',
      minStock: 30,
      location: 'Rak B-01',
      zone: 'B',
      status: '⚠️ Stok Minimum!',
    ),
    ItemModel(
      id: '3',
      sku: 'SKU-003',
      name: 'Pola Cutting L',
      category: 'Pola & Hasil Cutting',
      qty: 0,
      unit: 'Lusin',
      minStock: 15,
      location: 'Meja C-01',
      zone: 'C',
      status: '🚨 Stok Habis',
    ),
  ];

  group('AdminDashboardScreen Widget Tests', () {
    testWidgets(
        'AdminDashboardScreen renders KPI cards (Total SKU, Total Stok, Item Kritis)',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryListProvider
                .overrideWith((ref) => AsyncValue.data(sampleItems)),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(),
          ),
        ),
      );

      // Verify Screen Title
      expect(find.text('Dashboard Analitik Gudang'), findsOneWidget);

      // Verify KPI Labels
      expect(find.text('Total SKU'), findsOneWidget);
      expect(find.text('Total Stok'), findsOneWidget);
      expect(find.text('Item Kritis'), findsOneWidget);

      // Verify KPI Values: 3 SKUs, 110 total stock (100 + 10 + 0), 2 critical items (1 low stock + 1 out of stock)
      expect(find.text('3'), findsWidgets);
      expect(find.text('110'), findsOneWidget);
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('AdminDashboardScreen renders all 4 chart sections',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryListProvider
                .overrideWith((ref) => AsyncValue.data(sampleItems)),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(),
          ),
        ),
      );

      // Verify Chart Section Titles
      expect(find.text('Komposisi Stok per Zona'), findsOneWidget);
      expect(find.text('Aktivitas Inbound vs Outbound'), findsOneWidget);
      expect(find.text('Status Kesehatan Stok'), findsOneWidget);
      expect(find.text('Akurasi Audit Stock Opname'), findsOneWidget);

      // Verify Chart Widgets exist in the tree
      expect(find.byType(ZoneDistributionChart), findsOneWidget);
      expect(find.byType(InboundOutboundChart), findsOneWidget);
      expect(find.byType(StockHealthChart), findsOneWidget);
      expect(find.byType(AuditAccuracyGauge), findsOneWidget);
    });

    testWidgets(
        'Chart widgets and AdminDashboardScreen handle empty item lists gracefully without crashing',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inventoryListProvider
                .overrideWith((ref) => const AsyncValue.data(<ItemModel>[])),
          ],
          child: const MaterialApp(
            home: AdminDashboardScreen(),
          ),
        ),
      );

      // Should not throw and should display 0 for KPIs
      expect(find.text('Total SKU'), findsOneWidget);
      expect(find.text('Total Stok'), findsOneWidget);
      expect(find.text('Item Kritis'), findsOneWidget);
      expect(find.text('0'), findsWidgets);

      // All 4 chart sections must still be present
      expect(find.text('Komposisi Stok per Zona'), findsOneWidget);
      expect(find.text('Aktivitas Inbound vs Outbound'), findsOneWidget);
      expect(find.text('Status Kesehatan Stok'), findsOneWidget);
      expect(find.text('Akurasi Audit Stock Opname'), findsOneWidget);

      // Empty state inside ZoneDistributionChart
      expect(find.text('Belum ada data stok'), findsOneWidget);
    });
  });
}

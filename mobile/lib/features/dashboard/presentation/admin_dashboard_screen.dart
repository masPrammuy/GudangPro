import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../inventory/providers/inventory_providers.dart';
import 'widgets/audit_accuracy_gauge.dart';
import 'widgets/inbound_outbound_chart.dart';
import 'widgets/stock_health_chart.dart';
import 'widgets/zone_distribution_chart.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Dashboard Analitik Gudang',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.slateDark,
        foregroundColor: Colors.white,
      ),
      body: itemsAsync.when(
        data: (items) {
          final totalSku = items.length;
          final totalStock =
              items.fold<int>(0, (sum, item) => sum + item.qty);
          final criticalItems = items
              .where((i) => i.isLowStock || i.isOutOfStock)
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildKpiSection(totalSku, totalStock, criticalItems),
                const SizedBox(height: 16),
                ZoneDistributionChart(items: items),
                const SizedBox(height: 16),
                const InboundOutboundChart(),
                const SizedBox(height: 16),
                StockHealthChart(items: items),
                const SizedBox(height: 16),
                const AuditAccuracyGauge(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => Center(
          child: Text('Gagal memuat analitik: $err'),
        ),
      ),
    );
  }

  Widget _buildKpiSection(int totalSku, int totalStock, int criticalItems) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            label: 'Total SKU',
            value: '$totalSku',
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            label: 'Total Stok',
            value: '$totalStock',
            icon: Icons.layers_outlined,
            color: AppColors.emeraldSuccess,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            label: 'Item Kritis',
            value: '$criticalItems',
            icon: Icons.warning_amber_rounded,
            color:
                criticalItems > 0 ? AppColors.roseDanger : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

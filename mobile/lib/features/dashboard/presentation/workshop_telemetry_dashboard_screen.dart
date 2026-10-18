import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../inventory/providers/inventory_providers.dart';
import 'widgets/critical_stock_banner.dart';
import 'widgets/kpi_metric_cards.dart';
import 'widgets/quick_steps_banner.dart';
import 'widgets/zone_capacity_telemetry.dart';

class WorkshopTelemetryDashboardScreen extends ConsumerWidget {
  final VoidCallback onNavigateToInventory;

  const WorkshopTelemetryDashboardScreen({
    super.key,
    required this.onNavigateToInventory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('GudangPro Workshop Telemetry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppColors.darkSlatePrimary,
        foregroundColor: Colors.white,
      ),
      body: itemsAsync.when(
        data: (items) {
          final criticalItems = items.where((i) => i.isLowStock || i.isOutOfStock).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const QuickStepsBanner(),
                const SizedBox(height: 14),
                KpiMetricCards(items: items),
                const SizedBox(height: 14),
                const ZoneCapacityTelemetry(),
                if (criticalItems.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  CriticalStockBanner(
                    criticalItems: criticalItems,
                    onViewTablePressed: onNavigateToInventory,
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat telemetri: $err')),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../inventory/data/item_model.dart';

class KpiMetricCards extends StatelessWidget {
  final List<ItemModel> items;

  const KpiMetricCards({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final totalSku = items.length;
    int criticalCount = 0;
    for (final i in items) {
      if (i.isLowStock || i.isOutOfStock) criticalCount++;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;

        final card1 = _buildCard(
          title: 'Total Bahan & Baju (SKU)',
          value: totalSku > 0 ? '$totalSku' : '1.850',
          subtitle: '↑ +12% jenis barang aktif tercatat',
          subtitleColor: AppColors.emeraldSuccess,
          icon: Icons.grid_view_rounded,
          iconBgColor: Colors.blue.shade50,
          iconColor: const Color(0xFF2563EB),
        );

        final card2 = _buildCard(
          title: 'Bahan/Kain Masuk (Hari Ini)',
          value: '+142',
          subtitle: '↑ 8 Batch Inbound terverifikasi',
          subtitleColor: AppColors.emeraldSuccess,
          icon: Icons.arrow_downward_rounded,
          iconBgColor: const Color(0xFFECFDF5),
          iconColor: AppColors.emeraldSuccess,
        );

        final card3 = _buildCard(
          title: 'Baju Terkirim (Hari Ini)',
          value: '-85',
          subtitle: '↓ 15 Order Pengiriman kurir/kargo',
          subtitleColor: const Color(0xFFD97706),
          icon: Icons.arrow_upward_rounded,
          iconBgColor: Colors.orange.shade50,
          iconColor: const Color(0xFFD97706),
        );

        final card4 = _buildCard(
          title: 'Peringatan Stok Minimum',
          value: '$criticalCount',
          subtitle: 'Capai Batas Minimum Segera restock bahan',
          subtitleColor: const Color(0xFFD97706),
          valueColor: const Color(0xFFDC2626),
          icon: Icons.warning_amber_rounded,
          iconBgColor: Colors.red.shade50,
          iconColor: const Color(0xFFDC2626),
        );

        if (isSmall) {
          return Column(
            children: [
              Row(children: [Expanded(child: card1), const SizedBox(width: 8), Expanded(child: card2)]),
              const SizedBox(height: 8),
              Row(children: [Expanded(child: card3), const SizedBox(width: 8), Expanded(child: card4)]),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: card1),
            const SizedBox(width: 12),
            Expanded(child: card2),
            const SizedBox(width: 12),
            Expanded(child: card3),
            const SizedBox(width: 12),
            Expanded(child: card4),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    Color? valueColor,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: valueColor ?? AppColors.darkSlatePrimary),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: subtitleColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

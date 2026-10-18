import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../inventory/data/item_model.dart';

class ZoneDistributionChart extends StatelessWidget {
  final List<ItemModel> items;

  const ZoneDistributionChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    int zoneA = 0, zoneB = 0, zoneC = 0, zoneD = 0;
    for (final item in items) {
      if (item.zone == 'A') zoneA += item.qty;
      if (item.zone == 'B') zoneB += item.qty;
      if (item.zone == 'C') zoneC += item.qty;
      if (item.zone == 'D') zoneD += item.qty;
    }
    final total = zoneA + zoneB + zoneC + zoneD;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Komposisi Stok per Zona',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: total == 0
                  ? const Center(
                      child: Text(
                        'Belum ada data stok',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 36,
                        sections: [
                          if (zoneA > 0)
                            PieChartSectionData(
                              value: zoneA.toDouble(),
                              color: const Color(0xFF3B82F6),
                              title: 'A',
                              radius: 45,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          if (zoneB > 0)
                            PieChartSectionData(
                              value: zoneB.toDouble(),
                              color: const Color(0xFF8B5CF6),
                              title: 'B',
                              radius: 45,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          if (zoneC > 0)
                            PieChartSectionData(
                              value: zoneC.toDouble(),
                              color: const Color(0xFFF59E0B),
                              title: 'C',
                              radius: 45,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          if (zoneD > 0)
                            PieChartSectionData(
                              value: zoneD.toDouble(),
                              color: const Color(0xFF10B981),
                              title: 'D',
                              radius: 45,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegend(const Color(0xFF3B82F6), 'A: $zoneA'),
                _buildLegend(const Color(0xFF8B5CF6), 'B: $zoneB'),
                _buildLegend(const Color(0xFFF59E0B), 'C: $zoneC'),
                _buildLegend(const Color(0xFF10B981), 'D: $zoneD'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
      ],
    );
  }
}

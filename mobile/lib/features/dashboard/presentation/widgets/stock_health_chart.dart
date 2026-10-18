import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../inventory/data/item_model.dart';

class StockHealthChart extends StatelessWidget {
  final List<ItemModel> items;

  const StockHealthChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    int safe = 0, warning = 0, danger = 0;
    for (final item in items) {
      if (item.isOutOfStock) {
        danger++;
      } else if (item.isLowStock) {
        warning++;
      } else {
        safe++;
      }
    }

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
              'Status Kesehatan Stok',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHealthCard('Tersedia', safe, AppColors.emeraldSuccess),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildHealthCard('Stok Tipis', warning, AppColors.amberWarning),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildHealthCard('Habis', danger, AppColors.roseDanger),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

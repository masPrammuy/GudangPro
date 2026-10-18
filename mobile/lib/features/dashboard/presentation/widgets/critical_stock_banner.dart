import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../inventory/data/item_model.dart';

class CriticalStockBanner extends StatelessWidget {
  final List<ItemModel> criticalItems;
  final VoidCallback onViewTablePressed;

  const CriticalStockBanner({
    super.key,
    required this.criticalItems,
    required this.onViewTablePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_amber_rounded, size: 28, color: Color(0xFFD97706)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    const Text(
                      '⚠️ Peringatan: Stok Bahan / Baju Mencapai Batas Minimum!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${criticalItems.length} Item Kritis',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Segera lakukan restock bahan kain/aksesoris atau jadwal ulang proses potong untuk item berikut agar jalur jahit tidak terhenti:',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: criticalItems.map((item) {
                    final isZero = item.isOutOfStock;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isZero ? const Color(0xFFFCA5A5) : const Color(0xFFFDE68A)),
                      ),
                      child: Text(
                        isZero
                            ? '🚨 Habis: ${item.name} (${item.qty} / Min: ${item.minStock} ${item.unit})'
                            : '⚠️ ${item.name} (${item.qty} / Min: ${item.minStock} ${item.unit})',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isZero ? const Color(0xFFDC2626) : const Color(0xFFB45309),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onViewTablePressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkSlatePrimary,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              child: const Text('Lihat di Tabel ↓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}

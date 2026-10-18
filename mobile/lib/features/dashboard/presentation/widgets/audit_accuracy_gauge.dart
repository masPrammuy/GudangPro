import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AuditAccuracyGauge extends StatelessWidget {
  final double accuracy;
  final int netDiscrepancy;

  const AuditAccuracyGauge({
    super.key,
    this.accuracy = 0.984,
    this.netDiscrepancy = 0,
  });

  @override
  Widget build(BuildContext context) {
    final accuracyPercent = (accuracy * 100).toStringAsFixed(1);

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
              'Akurasi Audit Stock Opname',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: accuracy.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: AppColors.border,
              color: AppColors.emeraldSuccess,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Akurasi Sistem: $accuracyPercent%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.emeraldSuccess,
                  ),
                ),
                Text(
                  'Net Discrepancy: $netDiscrepancy Pcs',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

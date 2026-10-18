import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ZoneCapacityTelemetry extends StatelessWidget {
  const ZoneCapacityTelemetry({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dashboard_customize_outlined, size: 20, color: AppColors.darkSlatePrimary),
                    SizedBox(width: 8),
                    Text(
                      'Denah & Kapasitas 4 Zona Workshop Konveksi Pakaian',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkSlatePrimary),
                    ),
                  ],
                ),
                Text(
                  'Realtime Workshop Telemetry • Sentra Konveksi',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 850;

                final zA = _buildZoneCard(
                  dotColor: const Color(0xFFF59E0B),
                  title: 'ZONA A (Gudang Kain Roll)',
                  tag: '75% Terpakai',
                  tagColor: const Color(0xFFF59E0B),
                  tagBgColor: const Color(0xFFFEF3C7),
                  description: 'Katun Combed, Rayon, Fleece & Denim',
                  capacityText: 'Terisi: 450 / 600 Roll',
                  percentText: '75%',
                  progressValue: 0.75,
                  progressColor: const Color(0xFF3B82F6),
                );

                final zB = _buildZoneCard(
                  dotColor: const Color(0xFF10B981),
                  title: 'ZONA B (Aksesori & Benang)',
                  tag: '55% Stabil',
                  tagColor: const Color(0xFF059669),
                  tagBgColor: const Color(0xFFD1FAE5),
                  description: 'Benang Jahit, Kancing, Resleting & Karet',
                  capacityText: 'Terisi: 330 / 600 Slot',
                  percentText: '55%',
                  progressValue: 0.55,
                  progressColor: const Color(0xFF059669),
                );

                final zC = _buildZoneCard(
                  dotColor: const Color(0xFFEF4444),
                  title: 'ZONA C (Meja Potong & WIP)',
                  tag: '88% Padat Jahit',
                  tagColor: const Color(0xFFDC2626),
                  tagBgColor: const Color(0xFFFEE2E2),
                  description: 'Pola Cutting, Bordir & Antrean Jahit',
                  capacityText: 'Antrean: 440 / 500 Batch',
                  percentText: '88%',
                  progressValue: 0.88,
                  progressColor: const Color(0xFFDC2626),
                );

                final zD = _buildZoneCard(
                  dotColor: const Color(0xFF3B82F6),
                  title: 'ZONA D (Baju Jadi Siap Kirim)',
                  tag: '40% Tersedia',
                  tagColor: const Color(0xFF0D9488),
                  tagBgColor: const Color(0xFFCCFBF1),
                  description: 'Kaos, Kemeja, Hoodie Lolos QC & Polybag',
                  capacityText: 'Terisi: 400 / 1.000 Pcs',
                  percentText: '40%',
                  progressValue: 0.40,
                  progressColor: const Color(0xFF0D9488),
                );

                if (isSmall) {
                  return Column(
                    children: [
                      Row(children: [Expanded(child: zA), const SizedBox(width: 8), Expanded(child: zB)]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: zC), const SizedBox(width: 8), Expanded(child: zD)]),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: zA),
                    const SizedBox(width: 10),
                    Expanded(child: zB),
                    const SizedBox(width: 10),
                    Expanded(child: zC),
                    const SizedBox(width: 10),
                    Expanded(child: zD),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneCard({
    required Color dotColor,
    required String title,
    required String tag,
    required Color tagColor,
    required Color tagBgColor,
    required String description,
    required String capacityText,
    required String percentText,
    required double progressValue,
    required Color progressColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.darkSlatePrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: tagBgColor, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    tag,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: tagColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  capacityText,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.darkSlatePrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(percentText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: progressColor)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 5,
              backgroundColor: Colors.grey.shade300,
              color: progressColor,
            ),
          ),
        ],
      ),
    );
  }
}

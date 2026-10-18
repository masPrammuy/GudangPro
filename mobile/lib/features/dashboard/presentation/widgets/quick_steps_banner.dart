import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class QuickStepsBanner extends StatelessWidget {
  const QuickStepsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;

        final step1 = _buildStepCard('1', 'Cek Stok Kain & Baju Jadi', 'Gunakan filter kategori di tabel untuk memantau stok roll kain, benang, kancing, atau baju siap kirim.');
        final step2 = _buildStepCard('2', 'Atur Batas Stok Minimum', 'Klik tombol biru "+ Tambah Barang" dan isi batas minimum stok agar Anda selalu mendapat peringatan restock.');
        final step3 = _buildStepCard('3', 'Peringatan Otomatis Realtime', 'Saat stok mencapai atau di bawah batas minimum, banner peringatan kuning-merah dan notifikasi toast akan langsung muncul.');

        if (isSmall) {
          return Column(
            children: [
              step1,
              const SizedBox(height: 8),
              step2,
              const SizedBox(height: 8),
              step3,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: step1),
            const SizedBox(width: 12),
            Expanded(child: step2),
            const SizedBox(width: 12),
            Expanded(child: step3),
          ],
        );
      },
    );
  }

  Widget _buildStepCard(String number, String title, String description) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xFF2563EB),
              child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkSlatePrimary)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

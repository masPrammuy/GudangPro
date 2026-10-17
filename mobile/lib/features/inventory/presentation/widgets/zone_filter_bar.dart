import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/inventory_providers.dart';

class ZoneFilterBar extends ConsumerWidget {
  const ZoneFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedZone = ref.watch(selectedZoneProvider);
    final zones = ['Semua', 'A', 'B', 'C', 'D'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: zones.map((z) {
          final isSelected = selectedZone == z;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(z == 'Semua' ? 'Semua Zona' : 'Zona $z'),
              selected: isSelected,
              selectedColor: AppColors.slateDark,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textMain,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(color: isSelected ? AppColors.slateDark : AppColors.border),
              ),
              onSelected: (_) {
                ref.read(selectedZoneProvider.notifier).state = z;
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

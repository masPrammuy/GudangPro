import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    if (status.contains('Habis')) {
      bg = AppColors.roseDanger.withOpacity(0.12);
      fg = AppColors.roseDanger;
    } else if (status.contains('Minimum')) {
      bg = AppColors.amberWarning.withOpacity(0.12);
      fg = AppColors.amberWarning;
    } else {
      bg = AppColors.emeraldSuccess.withOpacity(0.12);
      fg = AppColors.emeraldSuccess;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

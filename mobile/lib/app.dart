import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/adaptive_scaffold.dart';
import 'features/audit/presentation/audit_screen.dart';
import 'features/inbound/presentation/inbound_screen.dart';
import 'features/inventory/presentation/inventory_screen.dart';
import 'features/outbound/presentation/outbound_screen.dart';

class GudangProApp extends StatefulWidget {
  const GudangProApp({super.key});

  @override
  State<GudangProApp> createState() => _GudangProAppState();
}

class _GudangProAppState extends State<GudangProApp> {
  int _currentIndex = 0;

  static const _destinations = [
    AdaptiveDestination(icon: Icons.inventory_2, label: 'Stok'),
    AdaptiveDestination(icon: Icons.move_to_inbox, label: 'Bahan Masuk'),
    AdaptiveDestination(icon: Icons.outbox, label: 'Kirim Baju'),
    AdaptiveDestination(icon: Icons.fact_check, label: 'Opname'),
  ];

  static const _screens = [
    InventoryScreen(),
    InboundScreen(),
    OutboundScreen(),
    AuditScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GudangPro Apparel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.industrialTheme,
      home: AdaptiveScaffold(
        currentIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _destinations,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
    );
  }
}

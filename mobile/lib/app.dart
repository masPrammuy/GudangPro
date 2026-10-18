import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/adaptive_scaffold.dart';
import 'features/audit/presentation/audit_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/user_management_screen.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/dashboard/presentation/admin_dashboard_screen.dart';
import 'features/inbound/presentation/inbound_screen.dart';
import 'features/inventory/presentation/inventory_screen.dart';
import 'features/outbound/presentation/outbound_screen.dart';
import 'features/profile/presentation/profile_screen.dart';

class GudangProApp extends StatelessWidget {
  const GudangProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GudangPro Apparel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.industrialTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null || !currentUser.isActive) {
      return const LoginScreen();
    }
    return const MainNavigationScaffold();
  }
}

class MainNavigationScaffold extends ConsumerStatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  ConsumerState<MainNavigationScaffold> createState() =>
      _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState
    extends ConsumerState<MainNavigationScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isAdmin = user?.isAdmin == true;

    final destinations = isAdmin
        ? const [
            AdaptiveDestination(icon: Icons.dashboard, label: 'Dashboard'),
            AdaptiveDestination(icon: Icons.inventory_2, label: 'Stok'),
            AdaptiveDestination(icon: Icons.move_to_inbox, label: 'Bahan Masuk'),
            AdaptiveDestination(icon: Icons.outbox, label: 'Kirim Baju'),
            AdaptiveDestination(icon: Icons.fact_check, label: 'Opname'),
            AdaptiveDestination(icon: Icons.people, label: 'Pengguna'),
            AdaptiveDestination(icon: Icons.person, label: 'Profil'),
          ]
        : const [
            AdaptiveDestination(icon: Icons.inventory_2, label: 'Stok'),
            AdaptiveDestination(icon: Icons.move_to_inbox, label: 'Bahan Masuk'),
            AdaptiveDestination(icon: Icons.outbox, label: 'Kirim Baju'),
            AdaptiveDestination(icon: Icons.fact_check, label: 'Opname'),
            AdaptiveDestination(icon: Icons.person, label: 'Profil'),
          ];

    final screens = isAdmin
        ? const [
            AdminDashboardScreen(),
            InventoryScreen(),
            InboundScreen(),
            OutboundScreen(),
            AuditScreen(),
            UserManagementScreen(),
            ProfileScreen(),
          ]
        : const [
            InventoryScreen(),
            InboundScreen(),
            OutboundScreen(),
            AuditScreen(),
            ProfileScreen(),
          ];

    final safeIndex = _currentIndex < screens.length ? _currentIndex : 0;

    return AdaptiveScaffold(
      currentIndex: safeIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      destinations: destinations,
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
    );
  }
}

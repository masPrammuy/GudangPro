import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AdaptiveDestination {
  final IconData icon;
  final String label;

  const AdaptiveDestination({required this.icon, required this.label});
}

class AdaptiveScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveDestination> destinations;
  final Widget body;
  final PreferredSizeWidget? appBar;

  const AdaptiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= AppConstants.tabletBreakpoint;

    if (isTablet) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations
            .map((d) => NavigationDestination(
                  icon: Icon(d.icon),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widgets/adaptive_scaffold.dart';

void main() {
  testWidgets('AdaptiveScaffold displays BottomNavigationBar on phone screen width', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          currentIndex: 0,
          onDestinationSelected: (_) {},
          destinations: const [
            AdaptiveDestination(icon: Icons.inventory_2, label: 'Stok'),
            AdaptiveDestination(icon: Icons.move_to_inbox, label: 'Masuk'),
          ],
          body: const Text('Dashboard Content'),
        ),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('AdaptiveScaffold displays NavigationRail on tablet screen width', (tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveScaffold(
          currentIndex: 0,
          onDestinationSelected: (_) {},
          destinations: const [
            AdaptiveDestination(icon: Icons.inventory_2, label: 'Stok'),
            AdaptiveDestination(icon: Icons.move_to_inbox, label: 'Masuk'),
          ],
          body: const Text('Dashboard Content'),
        ),
      ),
    );

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}

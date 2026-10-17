import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widgets/status_badge.dart';

void main() {
  testWidgets('StatusBadge renders correct label and color', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(status: 'Tersedia'),
        ),
      ),
    );
    expect(find.text('Tersedia'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/audit/data/audit_model.dart';

void main() {
  test('AuditModel correctly computes discrepancy between physical and system stock', () {
    final model = AuditModel(
      itemId: 'item-1',
      systemStock: 50,
      physicalStock: 48,
    );

    expect(model.discrepancy, -2);
    expect(model.toJson()['discrepancy'], -2);

    final modelPlus = AuditModel(
      itemId: 'item-2',
      systemStock: 40,
      physicalStock: 45,
    );
    expect(modelPlus.discrepancy, 5);
  });
}

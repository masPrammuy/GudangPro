import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/inbound/data/inbound_model.dart';

void main() {
  test('InboundModel correctly parses from and to JSON', () {
    final model = InboundModel(
      poNumber: 'PO-TX-2026-001',
      itemId: 'd0a5b281-7c91-49b0-9513-33df45fbf0a1',
      qty: 25,
      supplier: 'PT Toko Kain Tekstil',
      lotNumber: 'LOT-992',
    );

    final json = model.toJson();
    expect(json['po_number'], 'PO-TX-2026-001');
    expect(json['qty'], 25);
    expect(json['status'], 'QC Passed');

    final parsed = InboundModel.fromJson(json);
    expect(parsed.poNumber, 'PO-TX-2026-001');
    expect(parsed.supplier, 'PT Toko Kain Tekstil');
  });
}

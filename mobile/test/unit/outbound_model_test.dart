import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/outbound/data/outbound_model.dart';

void main() {
  test('OutboundModel correctly serializes for Supabase DO insert', () {
    final model = OutboundModel(
      doNumber: 'DO-GP-2026-001',
      itemId: 'd0a5b281-7c91-49b0-9513-33df45fbf0a1',
      qty: 10,
      recipient: 'Distributor Apparel Jakarta',
      courier: 'JNE Trucking',
      notes: 'Pengiriman batch 1',
    );

    final json = model.toJson();
    expect(json['do_number'], 'DO-GP-2026-001');
    expect(json['qty'], 10);
    expect(json['status'], 'Terkirim');
  });
}

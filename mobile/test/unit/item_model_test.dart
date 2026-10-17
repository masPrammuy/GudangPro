import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/inventory/data/item_model.dart';

void main() {
  test('ItemModel correctly parses from and to Supabase JSON', () {
    final json = {
      'id': 'd0a5b281-7c91-49b0-9513-33df45fbf0a1',
      'sku': 'KAN-CMB-01',
      'name': 'Kain Katun Combed 30s',
      'category': 'Kain & Bahan Baku',
      'qty': 45,
      'unit': 'Roll',
      'min_stock': 15,
      'location': 'Rak Kain A-01',
      'zone': 'A',
      'status': 'Tersedia',
    };

    final item = ItemModel.fromJson(json);
    expect(item.sku, 'KAN-CMB-01');
    expect(item.qty, 45);
    expect(item.isLowStock, false);
    expect(item.isOutOfStock, false);
    expect(item.canDispatch(20), true);
    expect(item.canDispatch(50), false); // Anti over-shipping guard
  });
}

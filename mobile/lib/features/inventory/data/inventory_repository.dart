import 'package:supabase_flutter/supabase_flutter.dart';
import 'item_model.dart';

class InventoryRepository {
  final SupabaseClient? _client;

  InventoryRepository([this._client]);

  SupabaseClient get client => _client ?? Supabase.instance.client;

  Stream<List<ItemModel>> watchInventoryStream() {
    try {
      return client
          .from('inventory_items')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: true)
          .map((data) => data.map((json) => ItemModel.fromJson(json)).toList());
    } catch (_) {
      // Fallback empty stream for test/mock environment
      return const Stream.empty();
    }
  }

  Future<List<ItemModel>> fetchInventory() async {
    try {
      final res = await client
          .from('inventory_items')
          .select()
          .order('created_at', ascending: true);
      return (res as List).map((json) => ItemModel.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }
}

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'item_model.dart';

class InventoryRepository {
  final SupabaseClient? _client;
  late final List<ItemModel> _localItems;
  late final StreamController<List<ItemModel>> _localStreamController;

  static final List<ItemModel> defaultItems = [
    ItemModel(
      id: 'kan-cmb-01',
      sku: 'KAN-CMB-01',
      name: 'Kain Katun Combed 30s Hitam Reaktif',
      category: 'Kain & Bahan Baku',
      qty: 45,
      unit: 'Roll',
      minStock: 15,
      location: 'Rak Kain A-01',
      zone: 'A',
      status: 'Tersedia',
    ),
    ItemModel(
      id: 'bng-jht-08',
      sku: 'BNG-JHT-08',
      name: 'Benang Jahit Spun Polyester Putih Extra (40/2)',
      category: 'Aksesoris Jahit',
      qty: 8,
      unit: 'Lusin',
      minStock: 20,
      location: 'Rak Aksesoris B-02',
      zone: 'B',
      status: '⚠️ Stok Minimum!',
    ),
    ItemModel(
      id: 'knc-kmg-14',
      sku: 'KNC-KMG-14',
      name: 'Kancing Kemeja Lubang Empat 14mm Putih Mutiara',
      category: 'Aksesoris Jahit',
      qty: 450,
      unit: 'Pcs',
      minStock: 100,
      location: 'Rak Aksesoris B-05',
      zone: 'B',
      status: 'Tersedia',
    ),
    ItemModel(
      id: 'cut-kaos-l',
      sku: 'CUT-KAOS-L',
      name: 'Pola Potong Kaos Polos Lengan Pendek Combed (L)',
      category: 'Pola & Hasil Cutting',
      qty: 65,
      unit: 'Lusin',
      minStock: 25,
      location: 'Meja Cutting C-01',
      zone: 'C',
      status: 'Tersedia',
    ),
    ItemModel(
      id: 'bju-ovr-blk',
      sku: 'BJU-OVR-BLK',
      name: 'Kaos Polos Oversize Katun 24s Hitam Size L (Siap Kirim)',
      category: 'Baju Jadi (Siap Kirim)',
      qty: 6,
      unit: 'Pcs',
      minStock: 30,
      location: 'Rak Baju D-03',
      zone: 'D',
      status: '⚠️ Stok Minimum!',
    ),
    ItemModel(
      id: 'rst-ykk-60',
      sku: 'RST-YKK-60',
      name: 'Resleting Jaket YKK Metal Open End 60cm Hitam',
      category: 'Aksesoris Jahit',
      qty: 0,
      unit: 'Pcs',
      minStock: 50,
      location: 'Rak Aksesoris B-01',
      zone: 'B',
      status: '🚨 Stok Habis',
    ),
    ItemModel(
      id: 'bju-kmg-fln',
      sku: 'BJU-KMG-FLN',
      name: 'Kemeja Pria Flanel Kotak Tartan Lengan Panjang (M)',
      category: 'Baju Jadi (Siap Kirim)',
      qty: 32,
      unit: 'Pcs',
      minStock: 15,
      location: 'Rak Baju D-01',
      zone: 'D',
      status: 'Tersedia',
    ),
    ItemModel(
      id: 'pkg-opp-30',
      sku: 'PKG-OPP-30',
      name: 'Plastik Kemasan Baju OPP Seal Tebal 30x40 cm + Hangtag',
      category: 'Packaging & Hangtag',
      qty: 500,
      unit: 'Pcs',
      minStock: 150,
      location: 'Rak Packing D-05',
      zone: 'D',
      status: 'Tersedia',
    ),
  ];

  InventoryRepository([this._client]) {
    _localItems = List.from(defaultItems);
    _localStreamController = StreamController<List<ItemModel>>.broadcast();
  }

  SupabaseClient? get client {
    if (_client != null) return _client;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Stream<List<ItemModel>> watchInventoryStream() async* {
    final sb = client;
    if (sb != null) {
      try {
        yield* sb
            .from('inventory_items')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: true)
            .map((data) => data.map((json) => ItemModel.fromJson(json)).toList());
        return;
      } catch (_) {
        // Fallback to local stream below
      }
    }
    yield List.from(_localItems);
    yield* _localStreamController.stream;
  }

  Future<List<ItemModel>> fetchInventory() async {
    final sb = client;
    if (sb != null) {
      try {
        final res = await sb
            .from('inventory_items')
            .select()
            .order('created_at', ascending: true);
        return (res as List).map((json) => ItemModel.fromJson(json)).toList();
      } catch (_) {
        // Fallback to local
      }
    }
    return List.from(_localItems);
  }

  void addStock(String itemId, int qty) {
    final index = _localItems.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      final old = _localItems[index];
      final newQty = old.qty + qty;
      final newStatus = newQty <= 0
          ? '🚨 Stok Habis'
          : (newQty <= old.minStock ? '⚠️ Stok Minimum!' : 'Tersedia');
      _localItems[index] = ItemModel(
        id: old.id,
        sku: old.sku,
        name: old.name,
        category: old.category,
        qty: newQty,
        unit: old.unit,
        minStock: old.minStock,
        location: old.location,
        zone: old.zone,
        status: newStatus,
      );
      _localStreamController.add(List.from(_localItems));
    }
  }

  void deductStock(String itemId, int qty) {
    final index = _localItems.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      final old = _localItems[index];
      final newQty = old.qty - qty;
      final newStatus = newQty <= 0
          ? '🚨 Stok Habis'
          : (newQty <= old.minStock ? '⚠️ Stok Minimum!' : 'Tersedia');
      _localItems[index] = ItemModel(
        id: old.id,
        sku: old.sku,
        name: old.name,
        category: old.category,
        qty: newQty < 0 ? 0 : newQty,
        unit: old.unit,
        minStock: old.minStock,
        location: old.location,
        zone: old.zone,
        status: newStatus,
      );
      _localStreamController.add(List.from(_localItems));
    }
  }

  void setPhysicalStock(String itemId, int physicalStock) {
    final index = _localItems.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      final old = _localItems[index];
      final newStatus = physicalStock <= 0
          ? '🚨 Stok Habis'
          : (physicalStock <= old.minStock ? '⚠️ Stok Minimum!' : 'Tersedia');
      _localItems[index] = ItemModel(
        id: old.id,
        sku: old.sku,
        name: old.name,
        category: old.category,
        qty: physicalStock,
        unit: old.unit,
        minStock: old.minStock,
        location: old.location,
        zone: old.zone,
        status: newStatus,
      );
      _localStreamController.add(List.from(_localItems));
    }
  }
}

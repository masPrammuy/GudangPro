import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/inventory_repository.dart';
import '../data/item_model.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository();
});

final selectedZoneProvider = StateProvider<String>((ref) => 'Semua');

final inventoryStreamProvider = StreamProvider<List<ItemModel>>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.watchInventoryStream();
});

final inventoryListProvider = Provider<AsyncValue<List<ItemModel>>>((ref) {
  final streamAsync = ref.watch(inventoryStreamProvider);
  final selectedZone = ref.watch(selectedZoneProvider);

  return streamAsync.whenData((items) {
    if (selectedZone == 'Semua') return items;
    return items.where((i) => i.zone == selectedZone).toList();
  });
});

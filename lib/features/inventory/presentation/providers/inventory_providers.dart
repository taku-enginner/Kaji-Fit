import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/database_provider.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../domain/entities/inventory_item.dart';

/// 在庫リポジトリのプロバイダー
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return InventoryRepository(isar);
});

/// すべての在庫アイテムを監視するプロバイダー
final allInventoryItemsProvider = StreamProvider<List<InventoryItem>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.watchAllItems();
});

/// 在庫アイテムを追加するプロバイダー
final addInventoryItemProvider =
    Provider<Future<void> Function(InventoryItem)>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return (item) => repository.addItem(item);
});

/// 在庫アイテムを削除するプロバイダー
final deleteInventoryItemProvider =
    Provider<Future<void> Function(int)>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return (id) => repository.deleteItem(id);
});

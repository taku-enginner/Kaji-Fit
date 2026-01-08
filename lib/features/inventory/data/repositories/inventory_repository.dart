import 'package:isar/isar.dart';
import '../../domain/entities/inventory_item.dart';

/// 在庫アイテムのリポジトリ
class InventoryRepository {
  final Isar _isar;

  InventoryRepository(this._isar);

  /// すべての在庫アイテムを取得
  Stream<List<InventoryItem>> watchAllItems() {
    return _isar.inventoryItems
        .where()
        .sortByAddedAtDesc()
        .watch(fireImmediately: true);
  }

  /// すべての在庫アイテムを一度だけ取得
  Future<List<InventoryItem>> getAllItems() async {
    return await _isar.inventoryItems.where().sortByAddedAtDesc().findAll();
  }

  /// 在庫アイテムを追加
  Future<void> addItem(InventoryItem item) async {
    await _isar.writeTxn(() async {
      await _isar.inventoryItems.put(item);
    });
  }

  /// 在庫アイテムを削除
  Future<void> deleteItem(int id) async {
    await _isar.writeTxn(() async {
      await _isar.inventoryItems.delete(id);
    });
  }

  /// 在庫アイテムを更新
  Future<void> updateItem(InventoryItem item) async {
    await _isar.writeTxn(() async {
      await _isar.inventoryItems.put(item);
    });
  }

  /// 名前で在庫アイテムを検索
  Future<List<InventoryItem>> searchByName(String query) async {
    return await _isar.inventoryItems
        .filter()
        .nameContains(query, caseSensitive: false)
        .sortByAddedAtDesc()
        .findAll();
  }
}

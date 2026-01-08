import 'package:isar/isar.dart';

part 'inventory_item.g.dart';

/// 在庫アイテム
@Collection()
class InventoryItem {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  late DateTime addedAt;

  DateTime? expiresAt;

  String? category;

  InventoryItem({
    required this.name,
    required this.addedAt,
    this.expiresAt,
    this.category,
  });

  /// 有効期限が切れているかどうか
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 有効期限が近い（3日以内）かどうか
  bool get isExpiringSoon {
    if (expiresAt == null) return false;
    final daysUntilExpiry = expiresAt!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
  }
}

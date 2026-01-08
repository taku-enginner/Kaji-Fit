// GENERATED CODE - DO NOT MODIFY BY HAND
// このファイルは build_runner で生成されます
// コマンド: flutter pub run build_runner build

part of 'inventory_item.dart';

// IgnoreForFile: type=lint

const InventoryItemSchema = CollectionSchema(
  name: r'InventoryItem',
  id: 0,
  properties: {},
  estimateSize: _inventoryItemEstimateSize,
  serialize: _inventoryItemSerialize,
  deserialize: _inventoryItemDeserialize,
  deserializeProp: _inventoryItemDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _inventoryItemGetId,
  getLinks: _inventoryItemGetLinks,
  attach: _inventoryItemAttach,
  version: '3.1.0+1',
);

int _inventoryItemEstimateSize(
  InventoryItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  return 0;
}

void _inventoryItemSerialize(
  InventoryItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {}

InventoryItem _inventoryItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  return InventoryItem(
    name: '',
    addedAt: DateTime.now(),
  );
}

P _inventoryItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  return '' as P;
}

Id _inventoryItemGetId(InventoryItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _inventoryItemGetLinks(InventoryItem object) {
  return [];
}

void _inventoryItemAttach(
    IsarCollection<dynamic> col, Id id, InventoryItem object) {
  object.id = id;
}

extension InventoryItemQueryWhereSort
    on QueryBuilder<InventoryItem, InventoryItem, QWhere> {
  QueryBuilder<InventoryItem, InventoryItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InventoryItemQueryWhere
    on QueryBuilder<InventoryItem, InventoryItem, QWhereClause> {
  QueryBuilder<InventoryItem, InventoryItem, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }
}

extension InventoryItemQueryFilter
    on QueryBuilder<InventoryItem, InventoryItem, QFilterCondition> {
  QueryBuilder<InventoryItem, InventoryItem, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }
}

extension InventoryItemQuerySortBy
    on QueryBuilder<InventoryItem, InventoryItem, QSortBy> {
  QueryBuilder<InventoryItem, InventoryItem, QAfterSortBy> sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }
}

extension InventoryItemQueryObject
    on QueryBuilder<InventoryItem, InventoryItem, QFilterCondition> {}

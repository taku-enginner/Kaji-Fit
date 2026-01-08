/// 家事タイプ
enum KajiActivityType {
  futonDrying(mets: 4.0, displayName: '布団干し'),
  sheetChanging(mets: 3.3, displayName: 'シーツ交換');

  final double mets;
  final String displayName;

  const KajiActivityType({
    required this.mets,
    required this.displayName,
  });

  /// 文字列からKajiActivityTypeを取得
  static KajiActivityType? fromString(String value) {
    for (final type in KajiActivityType.values) {
      if (type.name == value) {
        return type;
      }
    }
    return null;
  }
}

/// METs (Metabolic Equivalent of Task) 定数
/// 家事活動の運動強度を表す値
class MetsValues {
  // 家事活動のMETs値
  static const double futonDrying = 4.0; // 布団干し/上げ下ろし
  static const double sheetChanging = 3.3; // シーツ交換

  /// カロリー計算式: METs × 体重(kg) × 時間(h) × 1.05
  /// @param mets METs値
  /// @param weightKg 体重（kg）
  /// @param durationMinutes 活動時間（分）
  /// @return 消費カロリー（kcal）
  static double calculateCalories({
    required double mets,
    required double weightKg,
    required double durationMinutes,
  }) {
    final durationHours = durationMinutes / 60.0;
    return mets * weightKg * durationHours * 1.05;
  }
}

import '../../domain/entities/kaji_activity_type.dart';
import '../../domain/entities/workout_session.dart';

/// カロリー計算サービス
class CalorieCalculator {
  /// METs × 体重(kg) × 時間(h) × 1.05
  static double calculateCalories({
    required double mets,
    required double weightKg,
    required double durationMinutes,
  }) {
    final durationHours = durationMinutes / 60.0;
    return mets * weightKg * durationHours * 1.05;
  }

  /// 家事タイプから消費カロリーを計算
  static double calculateFromActivityType({
    required KajiActivityType activityType,
    required double weightKg,
    required double durationMinutes,
  }) {
    return calculateCalories(
      mets: activityType.mets,
      weightKg: weightKg,
      durationMinutes: durationMinutes,
    );
  }

  /// ワークアウトセッションを作成
  static WorkoutSession createWorkoutSession({
    required DateTime startTime,
    required DateTime endTime,
    required KajiActivityType activityType,
    required double activityDurationMinutes,
    required double weightKg,
  }) {
    final calories = calculateFromActivityType(
      activityType: activityType,
      weightKg: weightKg,
      durationMinutes: activityDurationMinutes,
    );

    return WorkoutSession.create(
      startTime: startTime,
      endTime: endTime,
      activityType: activityType,
      durationMinutes: activityDurationMinutes,
      caloriesBurned: calories,
      weightKg: weightKg,
    );
  }

  /// カロリーが異常値かチェック
  /// 1分で100kcal超は警告
  static bool isAbnormalCalories({
    required double calories,
    required double durationMinutes,
  }) {
    if (durationMinutes <= 0) return false;
    final caloriesPerMinute = calories / durationMinutes;
    return caloriesPerMinute > 100.0;
  }
}

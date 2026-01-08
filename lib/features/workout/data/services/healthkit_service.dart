import 'package:health/health.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/workout_session.dart';

/// HealthKit連携サービス
class HealthKitService {
  final Health _health = Health();

  /// HealthKitへのアクセス権限をリクエスト
  Future<(bool, String?)> requestAuthorization() async {
    final types = [
      HealthDataType.WORKOUT,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];

    try {
      // 権限をリクエスト（読み取りと書き込み両方）
      final authorized = await _health.requestAuthorization(
        types,
        permissions: [
          HealthDataAccess.WRITE,
          HealthDataAccess.WRITE,
        ],
      );

      if (!authorized) {
        return (false, 'HealthKitの権限が拒否されました');
      }

      return (true, null);
    } catch (e) {
      debugPrint('HealthKit authorization error: $e');
      return (false, 'エラー: $e');
    }
  }

  /// ワークアウトセッションをHealthKitに書き込む
  Future<(bool, String?)> writeWorkoutSession(WorkoutSession session) async {
    try {
      // 権限確認
      final (hasAuth, error) = await requestAuthorization();
      if (!hasAuth) {
        return (false, error ?? 'HealthKitの権限がありません');
      }

      debugPrint('Writing workout to HealthKit:');
      debugPrint('  Activity: ${session.activityType.displayName}');
      debugPrint('  Start: ${session.startTime}');
      debugPrint('  End: ${session.endTime}');
      debugPrint('  Calories (raw): ${session.caloriesBurned}');
      debugPrint('  Calories (rounded): ${session.caloriesBurned.round()}');

      // ワークアウトデータを作成（四捨五入して整数に、最小値1kcal）
      // HealthKitは0kcalのワークアウトを正しく表示しない場合があるため
      final caloriesRounded = session.caloriesBurned.round();
      final caloriesToWrite = caloriesRounded > 0 ? caloriesRounded : 1;

      debugPrint('  Calories (to write): $caloriesToWrite');

      final success = await _health.writeWorkoutData(
        activityType: HealthWorkoutActivityType.OTHER,
        start: session.startTime,
        end: session.endTime,
        totalEnergyBurned: caloriesToWrite,
        totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
        title: 'Kaji-Fit: ${session.activityType.displayName}',
      );

      debugPrint('HealthKit write result: $success');

      // エネルギーデータを個別に書き込む（より確実な方法）
      // ワークアウトとは別にアクティブエネルギーとして書き込む
      if (success) {
        try {
          // 小数点以下も含めた正確な値を書き込む
          final energyValue = session.caloriesBurned > 0 ? session.caloriesBurned : 1.0;
          debugPrint('  Writing energy data: $energyValue kcal');

          final energyWritten = await _health.writeHealthData(
            value: energyValue,
            type: HealthDataType.ACTIVE_ENERGY_BURNED,
            startTime: session.startTime,
            endTime: session.endTime,
            unit: HealthDataUnit.KILOCALORIE,
          );
          debugPrint('  Energy data write result: $energyWritten');
        } catch (e) {
          debugPrint('  Energy data write error (non-fatal): $e');
          // エネルギーデータの書き込みに失敗してもワークアウトは成功とする
        }
      }

      if (!success) {
        return (false, 'HealthKitへの書き込みに失敗しました');
      }

      return (true, null);
    } catch (e) {
      debugPrint('HealthKit write error: $e');
      return (false, 'エラー: $e');
    }
  }

  /// 複数のワークアウトセッションをHealthKitに書き込む
  Future<List<(bool, String?)>> writeMultipleWorkoutSessions(
      List<WorkoutSession> sessions) async {
    final results = <(bool, String?)>[];
    for (final session in sessions) {
      final result = await writeWorkoutSession(session);
      results.add(result);
    }
    return results;
  }

  /// HealthKitからワークアウトデータを読み込む（今日のデータ）
  Future<List<HealthDataPoint>> getTodayWorkouts() async {
    try {
      final (hasAuth, _) = await requestAuthorization();
      if (!hasAuth) {
        return [];
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final healthData = await _health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: endOfDay,
        types: [HealthDataType.WORKOUT],
      );

      return healthData;
    } catch (e) {
      debugPrint('HealthKit read error: $e');
      return [];
    }
  }
}

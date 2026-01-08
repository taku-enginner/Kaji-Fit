import 'package:health/health.dart';
import '../../domain/entities/workout_session.dart';

/// HealthKit連携サービス
class HealthKitService {
  final Health _health = Health();

  /// HealthKitへのアクセス権限をリクエスト
  Future<bool> requestAuthorization() async {
    final types = [
      HealthDataType.WORKOUT,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];

    try {
      final hasPermissions = await _health.hasPermissions(types);
      if (hasPermissions != null && hasPermissions) {
        return true;
      }

      final authorized = await _health.requestAuthorization(types);
      return authorized;
    } catch (e) {
      return false;
    }
  }

  /// ワークアウトセッションをHealthKitに書き込む
  Future<bool> writeWorkoutSession(WorkoutSession session) async {
    try {
      // 権限確認
      final hasAuth = await requestAuthorization();
      if (!hasAuth) {
        return false;
      }

      // ワークアウトデータを作成
      final success = await _health.writeWorkoutData(
        activityType: HealthWorkoutActivityType.OTHER,
        start: session.startTime,
        end: session.endTime,
        totalEnergyBurned: session.caloriesBurned.toInt(),
        totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
        title: 'Kaji-Fit: ${session.activityType.displayName}',
      );

      return success;
    } catch (e) {
      return false;
    }
  }

  /// 複数のワークアウトセッションをHealthKitに書き込む
  Future<List<bool>> writeMultipleWorkoutSessions(
      List<WorkoutSession> sessions) async {
    final results = <bool>[];
    for (final session in sessions) {
      final success = await writeWorkoutSession(session);
      results.add(success);
    }
    return results;
  }

  /// HealthKitからワークアウトデータを読み込む（今日のデータ）
  Future<List<HealthDataPoint>> getTodayWorkouts() async {
    try {
      final hasAuth = await requestAuthorization();
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
      return [];
    }
  }
}

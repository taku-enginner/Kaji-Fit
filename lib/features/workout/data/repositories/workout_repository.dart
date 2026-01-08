import 'package:isar/isar.dart';
import '../../domain/entities/workout_session.dart';

/// ワークアウトセッションのリポジトリ
class WorkoutRepository {
  final Isar _isar;

  WorkoutRepository(this._isar);

  /// ワークアウトセッションを保存
  Future<void> saveWorkoutSession(WorkoutSession session) async {
    await _isar.writeTxn(() async {
      await _isar.workoutSessions.put(session);
    });
  }

  /// すべてのワークアウトセッションを取得
  Future<List<WorkoutSession>> getAllWorkoutSessions() async {
    return await _isar.workoutSessions.where().sortByStartTimeDesc().findAll();
  }

  /// 特定の日のワークアウトセッションを取得
  Future<List<WorkoutSession>> getWorkoutSessionsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await _isar.workoutSessions
        .where()
        .filter()
        .startTimeBetween(startOfDay, endOfDay)
        .sortByStartTimeDesc()
        .findAll();
  }

  /// 今日のワークアウトセッションを取得
  Future<List<WorkoutSession>> getTodayWorkoutSessions() async {
    return await getWorkoutSessionsByDate(DateTime.now());
  }

  /// 未同期のワークアウトセッションを取得（HealthKit用）
  Future<List<WorkoutSession>> getUnsyncedWorkoutSessions() async {
    return await _isar.workoutSessions
        .where()
        .filter()
        .syncedToHealthKitEqualTo(false)
        .findAll();
  }

  /// ワークアウトセッションを同期済みに更新
  Future<void> markAsSynced(WorkoutSession session) async {
    session.syncedToHealthKit = true;
    await _isar.writeTxn(() async {
      await _isar.workoutSessions.put(session);
    });
  }

  /// ワークアウトセッションを削除
  Future<void> deleteWorkoutSession(int id) async {
    await _isar.writeTxn(() async {
      await _isar.workoutSessions.delete(id);
    });
  }

  /// 今日の合計消費カロリーを取得
  Future<double> getTodayTotalCalories() async {
    final sessions = await getTodayWorkoutSessions();
    return sessions.fold<double>(0.0, (sum, session) => sum + session.caloriesBurned);
  }

  /// 今日の合計活動時間を取得（分）
  Future<double> getTodayTotalDuration() async {
    final sessions = await getTodayWorkoutSessions();
    return sessions.fold<double>(0.0, (sum, session) => sum + session.durationMinutes);
  }
}

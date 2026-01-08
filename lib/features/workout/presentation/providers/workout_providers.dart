import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/services/healthkit_service.dart';
import '../../../../shared/providers/database_provider.dart';

/// ワークアウトリポジトリのプロバイダー
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final database = ref.watch(databaseProvider).value;
  if (database == null) {
    throw Exception('Database not initialized');
  }
  return WorkoutRepository(database);
});

/// HealthKitサービスのプロバイダー
final healthKitServiceProvider = Provider<HealthKitService>((ref) {
  return HealthKitService();
});

/// 体重のプロバイダー（仮の値、後で設定画面から変更可能にする）
final userWeightProvider = StateProvider<double>((ref) {
  return 60.0; // デフォルト60kg
});

/// 今日の合計消費カロリーのプロバイダー
final todayTotalCaloriesProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return await repository.getTodayTotalCalories();
});

/// 今日の合計活動時間のプロバイダー
final todayTotalDurationProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return await repository.getTodayTotalDuration();
});

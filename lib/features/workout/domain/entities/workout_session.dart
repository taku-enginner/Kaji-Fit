import 'package:isar/isar.dart';
import 'kaji_activity_type.dart';

part 'workout_session.g.dart';

/// ワークアウトセッション
@collection
class WorkoutSession {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime startTime;

  late DateTime endTime;

  /// 家事タイプ（enum名を文字列として保存）
  @Index()
  late String activityTypeString;

  /// 活動時間（分）
  late double durationMinutes;

  /// 消費カロリー（kcal）
  late double caloriesBurned;

  /// HealthKitに同期済みか
  late bool syncedToHealthKit;

  /// 体重（kg）- カロリー計算に使用
  late double weightKg;

  /// 家事タイプ（transient - データベースに保存されない）
  @Ignore()
  KajiActivityType get activityType =>
      KajiActivityType.fromString(activityTypeString) ??
      KajiActivityType.futonDrying;

  set activityType(KajiActivityType value) {
    activityTypeString = value.name;
  }

  /// デフォルトコンストラクタ
  WorkoutSession();

  /// 名前付きコンストラクタ
  WorkoutSession.create({
    required this.startTime,
    required this.endTime,
    required KajiActivityType activityType,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.weightKg,
    this.syncedToHealthKit = false,
  }) {
    activityTypeString = activityType.name;
  }

  /// 合計経過時間（分）
  double get totalElapsedMinutes {
    return endTime.difference(startTime).inSeconds / 60.0;
  }
}

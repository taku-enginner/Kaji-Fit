import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/workout/domain/entities/workout_session.dart';

/// Isarデータベースプロバイダー
final databaseProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [WorkoutSessionSchema],
    directory: dir.path,
  );

  return isar;
});

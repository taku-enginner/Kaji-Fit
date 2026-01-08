import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/workout/domain/entities/workout_session.dart';
import '../../features/inventory/domain/entities/inventory_item.dart';

/// Isarデータベースプロバイダー
final databaseProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [WorkoutSessionSchema, InventoryItemSchema],
    directory: dir.path,
  );

  return isar;
});

/// 同期的にIsarインスタンスを取得するプロバイダー
final isarProvider = Provider<Isar>((ref) {
  final asyncValue = ref.watch(databaseProvider);
  return asyncValue.when(
    data: (isar) => isar,
    loading: () => throw Exception('Database is loading'),
    error: (error, stack) => throw error,
  );
});

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/motion_detector.dart';
import '../../data/services/calorie_calculator.dart';
import '../../domain/entities/kaji_activity_type.dart';
import '../../domain/entities/workout_session.dart';
import '../providers/workout_providers.dart';

/// ワークアウト計測画面
class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  final MotionDetector _motionDetector = MotionDetector();
  bool _isMonitoring = false;
  AccelerometerData? _latestData;
  bool _isActivityDetected = false;

  // タイマー関連
  DateTime? _startTime;
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;

  StreamSubscription<AccelerometerData>? _dataSubscription;
  StreamSubscription<bool>? _activitySubscription;

  @override
  void initState() {
    super.initState();

    // データストリームを購読
    _dataSubscription = _motionDetector.dataStream.listen((data) {
      setState(() {
        _latestData = data;
      });
    });

    // 活動検知ストリームを購読
    _activitySubscription = _motionDetector.activityStream.listen((isActive) {
      setState(() {
        _isActivityDetected = isActive;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dataSubscription?.cancel();
    _activitySubscription?.cancel();
    _motionDetector.dispose();
    super.dispose();
  }

  /// 計測開始
  void _startMonitoring() {
    setState(() {
      _isMonitoring = true;
      _startTime = DateTime.now();
      _elapsedTime = Duration.zero;
    });

    _motionDetector.reset();
    _motionDetector.startMonitoring();

    // 1秒ごとにタイマー更新
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        setState(() {
          _elapsedTime = DateTime.now().difference(_startTime!);
        });
      }
    });
  }

  /// 計測停止
  void _stopMonitoring() {
    setState(() {
      _isMonitoring = false;
    });

    _motionDetector.stopMonitoring();
    _timer?.cancel();

    // 結果を表示
    _showResults();
  }

  /// 結果表示ダイアログ
  void _showResults() async {
    final activityMinutes = _motionDetector.totalActivityMinutes;
    final weightKg = ref.read(userWeightProvider);
    final activityType = KajiActivityType.futonDrying;

    // ワークアウトセッション作成
    final workoutSession = CalorieCalculator.createWorkoutSession(
      startTime: _startTime!,
      endTime: DateTime.now(),
      activityType: activityType,
      activityDurationMinutes: activityMinutes,
      weightKg: weightKg,
    );

    // 異常値チェック
    final isAbnormal = CalorieCalculator.isAbnormalCalories(
      calories: workoutSession.caloriesBurned,
      durationMinutes: activityMinutes,
    );

    if (!mounted) return;

    // 確認ダイアログを表示
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('計測結果'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('活動: ${activityType.displayName}'),
            Text('計測時間: ${workoutSession.totalElapsedMinutes.toStringAsFixed(1)}分'),
            Text('活動時間: ${activityMinutes.toStringAsFixed(1)}分'),
            Text('消費カロリー: ${workoutSession.caloriesBurned.toStringAsFixed(1)} kcal'),
            const SizedBox(height: 8),
            Text(
              '体重: ${weightKg.toStringAsFixed(1)}kg',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (isAbnormal) ...[
              const SizedBox(height: 8),
              const Text(
                '⚠️ カロリー値が異常に高い可能性があります',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      await _saveWorkoutSession(workoutSession);
    }
  }

  /// ワークアウトセッションを保存
  Future<void> _saveWorkoutSession(WorkoutSession workoutSession) async {
    try {
      // データベースに保存
      final repository = ref.read(workoutRepositoryProvider);
      await repository.saveWorkoutSession(workoutSession);

      // HealthKitに同期するか確認
      if (!mounted) return;
      final shouldSync = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('HealthKit連携'),
          content: const Text('ヘルスケアアプリに同期しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('しない'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('同期する'),
            ),
          ],
        ),
      );

      if (shouldSync == true) {
        final healthKitService = ref.read(healthKitServiceProvider);
        final success =
            await healthKitService.writeWorkoutSession(workoutSession);

        if (success) {
          // 同期済みフラグを更新
          await repository.markAsSynced(workoutSession);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('HealthKitに同期しました')),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('HealthKitへの同期に失敗しました')),
          );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ワークアウトを保存しました')),
      );

      // プロバイダーを更新
      ref.invalidate(todayTotalCaloriesProvider);
      ref.invalidate(todayTotalDurationProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存に失敗しました: $e')),
      );
    }
  }

  /// 経過時間を分:秒形式で表示
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final weightKg = ref.watch(userWeightProvider);
    final todayCalories = ref.watch(todayTotalCaloriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('家事トレ計測'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 今日の統計を表示
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: todayCalories.when(
                data: (calories) => Text(
                  '今日: ${calories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(fontSize: 14),
                ),
                loading: () => const Text('...'),
                error: (error, stackTrace) => const Text(''),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // タイトル
            const Text(
              '布団干し',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '体重: ${weightKg.toStringAsFixed(1)}kg',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 経過時間表示
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    '経過時間',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    _formatDuration(_elapsedTime),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '活動時間: ${_motionDetector.totalActivitySeconds.toStringAsFixed(1)}秒',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 活動検知状態
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isActivityDetected
                    ? Colors.green.shade100
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isActivityDetected ? Icons.check_circle : Icons.cancel,
                    color: _isActivityDetected ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isActivityDetected ? '活動中' : '待機中',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isActivityDetected
                          ? Colors.green.shade900
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // スタート/ストップボタン
            ElevatedButton(
              onPressed: _isMonitoring ? _stopMonitoring : _startMonitoring,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMonitoring ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isMonitoring ? 'ストップ' : 'スタート',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 32),

            // デバッグ情報
            if (_isMonitoring && _latestData != null) ...[
              const Divider(),
              const Text(
                'デバッグ情報',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('X: ${_latestData!.x.toStringAsFixed(2)} m/s²'),
                        Text('Y: ${_latestData!.y.toStringAsFixed(2)} m/s²'),
                        Text('Z: ${_latestData!.z.toStringAsFixed(2)} m/s²'),
                        Text(
                            'Magnitude: ${_latestData!.magnitude.toStringAsFixed(2)} m/s²'),
                        Text(
                            '重力除去後: ${_latestData!.withoutGravity.toStringAsFixed(2)} m/s²'),
                        Text(
                            '平滑化後: ${_latestData!.smoothed.toStringAsFixed(2)} m/s²'),
                        Text('連続ピーク: ${_latestData!.consecutivePeaks}'),
                        Text('総ピーク数: ${_latestData!.totalPeaks}'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

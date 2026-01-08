import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/services/motion_detector.dart';
import '../../../../core/constants/mets_values.dart';

/// ワークアウト計測画面
class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
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
  void _showResults() {
    final activityMinutes = _motionDetector.totalActivityMinutes;
    final totalMinutes = _elapsedTime.inSeconds / 60.0;

    // 仮の体重（60kg）でカロリー計算
    const double weightKg = 60.0;
    final calories = MetsValues.calculateCalories(
      mets: MetsValues.futonDrying,
      weightKg: weightKg,
      durationMinutes: activityMinutes,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('計測結果'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('計測時間: ${totalMinutes.toStringAsFixed(1)}分'),
            Text('活動時間: ${activityMinutes.toStringAsFixed(1)}分'),
            Text('消費カロリー: ${calories.toStringAsFixed(1)} kcal'),
            const SizedBox(height: 8),
            const Text(
              '※体重60kgで計算',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// 経過時間を分:秒形式で表示
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('家事トレ計測'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            const SizedBox(height: 32),

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
                color: _isActivityDetected ? Colors.green.shade100 : Colors.grey.shade200,
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
                      color: _isActivityDetected ? Colors.green.shade900 : Colors.grey.shade700,
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
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              Container(
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
                    Text('Magnitude: ${_latestData!.magnitude.toStringAsFixed(2)} m/s²'),
                    Text('重力除去後: ${_latestData!.withoutGravity.toStringAsFixed(2)} m/s²'),
                    Text('平滑化後: ${_latestData!.smoothed.toStringAsFixed(2)} m/s²'),
                    Text('連続ピーク: ${_latestData!.consecutivePeaks}'),
                    Text('総ピーク数: ${_latestData!.totalPeaks}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

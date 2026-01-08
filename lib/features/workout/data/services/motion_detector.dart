import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../../core/utils/signal_processing.dart';

/// モーション検知サービス
/// accelerometerEventsから加速度データを取得し、信号処理を行う
class MotionDetector {
  static const int samplingRate = 50; // 50Hz
  static const int movingAverageWindow = 5; // 移動平均のウィンドウサイズ

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final PeakDetector _peakDetector;

  final List<double> _magnitudeHistory = []; // Magnitude履歴
  final List<double> _smoothedHistory = []; // 平滑化後の履歴

  // リアルタイムデータのストリーム
  final StreamController<AccelerometerData> _dataController =
      StreamController<AccelerometerData>.broadcast();

  // 活動検知のストリーム
  final StreamController<bool> _activityController =
      StreamController<bool>.broadcast();

  DateTime? _activityStartTime;
  double _totalActivitySeconds = 0.0;
  DateTime? _lastUpdateTime;

  MotionDetector({
    double peakThreshold = 2.0,
    double minPeakInterval = 0.5,
    double maxPeakInterval = 2.0,
    int minConsecutivePeaks = 3,
  }) : _peakDetector = PeakDetector(
          peakThreshold: peakThreshold,
          minPeakInterval: minPeakInterval,
          maxPeakInterval: maxPeakInterval,
          minConsecutivePeaks: minConsecutivePeaks,
        );

  /// データストリーム（デバッグ用）
  Stream<AccelerometerData> get dataStream => _dataController.stream;

  /// 活動検知ストリーム
  Stream<bool> get activityStream => _activityController.stream;

  /// 活動時間（秒）
  double get totalActivitySeconds => _totalActivitySeconds;

  /// 活動時間（分）
  double get totalActivityMinutes => _totalActivitySeconds / 60.0;

  /// 監視開始
  void startMonitoring() {
    if (_accelerometerSubscription != null) {
      return; // 既に監視中
    }

    _lastUpdateTime = DateTime.now();

    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final now = DateTime.now();

      // 1. Magnitude計算
      final magnitude = SignalProcessing.calculateMagnitude(
        event.x,
        event.y,
        event.z,
      );

      // 2. 重力除去
      final withoutGravity = SignalProcessing.removeGravity(magnitude);

      // Magnitude履歴に追加
      _magnitudeHistory.add(withoutGravity);
      if (_magnitudeHistory.length > 100) {
        // 直近100サンプルのみ保持
        _magnitudeHistory.removeAt(0);
      }

      // 3. ノイズ除去（移動平均）
      final smoothed = SignalProcessing.movingAverage(
        _magnitudeHistory,
        windowSize: movingAverageWindow,
      );

      _smoothedHistory.add(smoothed);
      if (_smoothedHistory.length > 100) {
        _smoothedHistory.removeAt(0);
      }

      // 4. ピーク検出 & パターン認識
      final isActive = _peakDetector.detectPeak(smoothed);

      // 活動時間の累積
      if (isActive) {
        if (_activityStartTime == null) {
          _activityStartTime = now;
          _activityController.add(true);
        }

        // 前回の更新からの経過時間を加算
        if (_lastUpdateTime != null) {
          final elapsed = now.difference(_lastUpdateTime!).inMilliseconds / 1000.0;
          _totalActivitySeconds += elapsed;
        }
      } else {
        if (_activityStartTime != null) {
          _activityStartTime = null;
          _activityController.add(false);
        }
      }

      _lastUpdateTime = now;

      // データをストリームに流す
      _dataController.add(AccelerometerData(
        x: event.x,
        y: event.y,
        z: event.z,
        magnitude: magnitude,
        withoutGravity: withoutGravity,
        smoothed: smoothed,
        isActive: isActive,
        consecutivePeaks: _peakDetector.consecutivePeakCount,
        totalPeaks: _peakDetector.peakCount,
      ));
    });
  }

  /// 監視停止
  void stopMonitoring() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

  /// リセット
  void reset() {
    _magnitudeHistory.clear();
    _smoothedHistory.clear();
    _peakDetector.reset();
    _activityStartTime = null;
    _totalActivitySeconds = 0.0;
    _lastUpdateTime = null;
  }

  /// クリーンアップ
  void dispose() {
    stopMonitoring();
    _dataController.close();
    _activityController.close();
  }
}

/// 加速度データのモデル
class AccelerometerData {
  final double x;
  final double y;
  final double z;
  final double magnitude;
  final double withoutGravity;
  final double smoothed;
  final bool isActive;
  final int consecutivePeaks;
  final int totalPeaks;

  AccelerometerData({
    required this.x,
    required this.y,
    required this.z,
    required this.magnitude,
    required this.withoutGravity,
    required this.smoothed,
    required this.isActive,
    required this.consecutivePeaks,
    required this.totalPeaks,
  });
}

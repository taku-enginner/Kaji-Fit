import 'dart:math';

/// 加速度センサーデータの信号処理ユーティリティ
class SignalProcessing {
  /// 3軸加速度からMagnitude（大きさ）を計算
  /// √(x² + y² + z²)
  static double calculateMagnitude(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
  }

  /// 重力除去（ハイパスフィルタ）
  /// 重力加速度 (9.8 m/s²) を除去して動的加速度のみを抽出
  static double removeGravity(double magnitude) {
    return (magnitude - 9.8).abs();
  }

  /// 移動平均フィルタ（ノイズ除去）
  /// @param values データポイントのリスト
  /// @param windowSize ウィンドウサイズ（デフォルト: 5サンプル）
  /// @return 平滑化された値
  static double movingAverage(List<double> values, {int windowSize = 5}) {
    if (values.isEmpty) return 0.0;
    if (values.length < windowSize) {
      // データが不足している場合は利用可能なデータの平均を返す
      return values.reduce((a, b) => a + b) / values.length;
    }

    // 最新のwindowSize個のデータの平均を計算
    final recentValues = values.sublist(values.length - windowSize);
    return recentValues.reduce((a, b) => a + b) / windowSize;
  }

  /// ピーク検出
  /// @param value 現在の値
  /// @param threshold ピーク判定の閾値（デフォルト: 2.0 m/s²）
  /// @return ピークと判定される場合true
  static bool isPeak(double value, {double threshold = 2.0}) {
    return value >= threshold;
  }
}

/// ピーク検出の履歴を管理するクラス
class PeakDetector {
  final double peakThreshold; // ピーク判定の閾値
  final double minPeakInterval; // ピーク間の最小間隔（秒）
  final double maxPeakInterval; // ピーク間の最大間隔（秒）
  final int minConsecutivePeaks; // 活動開始と判定する連続ピーク数

  final List<DateTime> _peakTimestamps = []; // ピークの時刻履歴
  bool _isActivityActive = false; // 活動中かどうか
  DateTime? _lastPeakTime; // 最後のピークの時刻
  int _consecutivePeakCount = 0; // 連続ピーク数

  PeakDetector({
    this.peakThreshold = 2.0,
    this.minPeakInterval = 0.5,
    this.maxPeakInterval = 2.0,
    this.minConsecutivePeaks = 3,
  });

  /// ピーク検出処理
  /// @param value 平滑化された加速度値
  /// @return 活動中の場合true
  bool detectPeak(double value) {
    final now = DateTime.now();

    // ピーク判定
    if (SignalProcessing.isPeak(value, threshold: peakThreshold)) {
      // 最後のピークからの経過時間を確認
      if (_lastPeakTime != null) {
        final timeSinceLastPeak =
            now.difference(_lastPeakTime!).inMilliseconds / 1000.0;

        // 最小間隔より短い場合はノイズとして無視
        if (timeSinceLastPeak < minPeakInterval) {
          return _isActivityActive;
        }

        // 最大間隔を超えた場合はパターンをリセット
        if (timeSinceLastPeak > maxPeakInterval) {
          _consecutivePeakCount = 1;
          _peakTimestamps.clear();
        } else {
          _consecutivePeakCount++;
        }
      } else {
        _consecutivePeakCount = 1;
      }

      _lastPeakTime = now;
      _peakTimestamps.add(now);

      // 連続ピーク数が閾値を超えたら活動開始
      if (_consecutivePeakCount >= minConsecutivePeaks) {
        _isActivityActive = true;
      }
    } else {
      // ピークでない場合、最後のピークから時間が経過していればリセット
      if (_lastPeakTime != null) {
        final timeSinceLastPeak =
            now.difference(_lastPeakTime!).inMilliseconds / 1000.0;
        if (timeSinceLastPeak > maxPeakInterval) {
          _isActivityActive = false;
          _consecutivePeakCount = 0;
          _peakTimestamps.clear();
        }
      }
    }

    return _isActivityActive;
  }

  /// リセット
  void reset() {
    _peakTimestamps.clear();
    _isActivityActive = false;
    _lastPeakTime = null;
    _consecutivePeakCount = 0;
  }

  /// 活動中かどうか
  bool get isActivityActive => _isActivityActive;

  /// 連続ピーク数
  int get consecutivePeakCount => _consecutivePeakCount;

  /// ピーク履歴数
  int get peakCount => _peakTimestamps.length;
}

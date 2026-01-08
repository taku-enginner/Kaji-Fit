import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 体重を管理するプロバイダー
final userWeightProvider =
    StateNotifierProvider<UserWeightNotifier, double?>((ref) {
  return UserWeightNotifier();
});

class UserWeightNotifier extends StateNotifier<double?> {
  static const String _weightKey = 'user_weight';

  UserWeightNotifier() : super(null) {
    _loadWeight();
  }

  Future<void> _loadWeight() async {
    final prefs = await SharedPreferences.getInstance();
    final weight = prefs.getDouble(_weightKey);
    state = weight;
  }

  Future<void> setWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_weightKey, weight);
    state = weight;
  }
}

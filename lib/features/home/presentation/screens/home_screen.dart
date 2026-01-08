import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../../shared/widgets/activity_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(allWorkoutSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaji-Fit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            onPressed: () {
              // TODO: レシピ画面へ遷移
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('レシピ機能は開発中です')),
              );
            },
          ),
        ],
      ),
      body: sessionsAsync.when(
        data: (sessions) => _buildContent(context, ref, sessions),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> sessions,
  ) {
    // 今日の日付
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    // 今日のセッションをフィルタ
    final todaySessions = sessions.where((session) {
      return session.startTime.isAfter(todayStart);
    }).toList();

    // 今日の合計カロリー計算
    final todayCalories = todaySessions.fold<double>(
      0,
      (sum, session) => sum + session.caloriesBurned,
    );

    // 今日の合計時間計算
    final todayMinutes = todaySessions.fold<double>(
      0,
      (sum, session) => sum + session.durationMinutes,
    );

    return CustomScrollView(
      slivers: [
        // ヘッダー統計
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('yyyy年MM月dd日 (E)', 'ja').format(today),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: '消費カロリー',
                        value: todayCalories.toStringAsFixed(0),
                        unit: 'kcal',
                        icon: Icons.local_fire_department,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        title: '活動時間',
                        value: todayMinutes.toStringAsFixed(0),
                        unit: '分',
                        icon: Icons.timer,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      '今日の家事トレ',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => context.go('/workout'),
                      icon: const Icon(Icons.add),
                      label: const Text('計測開始'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 今日のセッションリスト
        if (todaySessions.isEmpty)
          SliverFillRemaining(
            child: EmptyState(
              icon: Icons.fitness_center,
              title: 'まだ家事トレがありません',
              message: '計測を開始して、今日の家事を記録しましょう！',
              actionLabel: '計測を開始',
              onAction: () => context.go('/workout'),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final session = todaySessions[index];
                return ActivityCard(
                  session: session,
                  onTap: () {
                    // TODO: セッション詳細画面へ遷移
                  },
                );
              },
              childCount: todaySessions.length,
            ),
          ),

        // 最近のアクティビティ（今日以外）
        if (sessions.length > todaySessions.length) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '最近の履歴',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final recentSessions = sessions
                    .where((s) => !s.startTime.isAfter(todayStart))
                    .toList();
                if (index >= recentSessions.length) return null;

                final session = recentSessions[index];
                return ActivityCard(
                  session: session,
                  onTap: () {
                    // TODO: セッション詳細画面へ遷移
                  },
                );
              },
            ),
          ),
        ],

        // 下部パディング
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }
}

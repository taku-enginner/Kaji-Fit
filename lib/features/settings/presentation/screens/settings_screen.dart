import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weight = ref.watch(userWeightProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            title: 'ユーザー情報',
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: AppTheme.primaryColor),
                title: const Text('体重'),
                subtitle: Text(weight != null ? '$weight kg' : '未設定'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showWeightDialog(context, ref, weight),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'ヘルスケア連携',
            children: [
              ListTile(
                leading: const Icon(Icons.favorite, color: AppTheme.errorColor),
                title: const Text('HealthKit連携'),
                subtitle: const Text('ワークアウトデータを同期'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: HealthKit連携の有効/無効を切り替え
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('HealthKit連携設定は実装中です')),
                    );
                  },
                ),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'データ管理',
            children: [
              ListTile(
                leading: const Icon(Icons.delete_forever, color: AppTheme.errorColor),
                title: const Text('全データを削除'),
                subtitle: const Text('ワークアウト履歴と在庫データを削除'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDeleteAllDataDialog(context, ref),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'アプリについて',
            children: [
              const ListTile(
                leading: Icon(Icons.info, color: AppTheme.accentColor),
                title: Text('バージョン'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.description, color: AppTheme.accentColor),
                title: const Text('利用規約'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 利用規約画面へ遷移
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip, color: AppTheme.accentColor),
                title: const Text('プライバシーポリシー'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: プライバシーポリシー画面へ遷移
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showWeightDialog(BuildContext context, WidgetRef ref, double? currentWeight) {
    final controller = TextEditingController(
      text: currentWeight?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('体重を設定'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: '体重 (kg)',
            hintText: '例: 60.5',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(controller.text);
              if (weight != null && weight > 0) {
                ref.read(userWeightProvider.notifier).setWeight(weight);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('体重を設定しました')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('全データを削除'),
        content: const Text(
          'すべてのワークアウト履歴と在庫データが削除されます。\nこの操作は取り消せません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 全データ削除の実装
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('データ削除機能は実装中です')),
              );
            },
            child: const Text(
              '削除',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

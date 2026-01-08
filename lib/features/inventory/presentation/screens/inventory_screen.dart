import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/inventory_item.dart';
import '../providers/inventory_providers.dart';
import '../widgets/add_inventory_dialog.dart';
import '../widgets/inventory_item_card.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(allInventoryItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('在庫管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              // TODO: レシートスキャン機能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('レシートスキャン機能は開発中です')),
              );
            },
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) => _buildContent(context, ref, items),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context, ref),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<InventoryItem> items,
  ) {
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2,
        title: '在庫がありません',
        message: '食材を追加して在庫を管理しましょう',
        actionLabel: '食材を追加',
        onAction: () => _showAddItemDialog(context, ref),
      );
    }

    // カテゴリ別にグループ化
    final Map<String, List<InventoryItem>> groupedItems = {};
    for (final item in items) {
      final category = item.category ?? 'その他';
      if (!groupedItems.containsKey(category)) {
        groupedItems[category] = [];
      }
      groupedItems[category]!.add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final category = groupedItems.keys.elementAt(index);
        final categoryItems = groupedItems[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                category,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...categoryItems.map((item) => InventoryItemCard(
                  item: item,
                  onDelete: () => _deleteItem(context, ref, item),
                )),
          ],
        );
      },
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddInventoryDialog(
        onAdd: (item) {
          final addItem = ref.read(addInventoryItemProvider);
          addItem(item);
        },
      ),
    );
  }

  void _deleteItem(BuildContext context, WidgetRef ref, InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('「${item.name}」を削除しますか?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final deleteItem = ref.read(deleteInventoryItemProvider);
              deleteItem(item.id);
              Navigator.of(context).pop();
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

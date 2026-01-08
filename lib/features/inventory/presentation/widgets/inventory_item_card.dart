import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme.dart';
import '../../domain/entities/inventory_item.dart';

class InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onDelete;

  const InventoryItemCard({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildLeadingIcon(),
        title: Text(
          item.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '追加日: ${dateFormat.format(item.addedAt)}${_getExpiryText()}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: AppTheme.errorColor,
          onPressed: onDelete,
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    Color iconColor;
    IconData icon;

    if (item.isExpired) {
      iconColor = AppTheme.errorColor;
      icon = Icons.warning;
    } else if (item.isExpiringSoon) {
      iconColor = AppTheme.secondaryColor;
      icon = Icons.access_time;
    } else {
      iconColor = AppTheme.primaryColor;
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: iconColor),
    );
  }

  String _getExpiryText() {
    if (item.expiresAt == null) return '';

    final dateFormat = DateFormat('MM/dd');
    if (item.isExpired) {
      return ' (期限切れ: ${dateFormat.format(item.expiresAt!)})';
    } else if (item.isExpiringSoon) {
      final daysLeft = item.expiresAt!.difference(DateTime.now()).inDays;
      return ' (あと${daysLeft}日)';
    } else {
      return ' (期限: ${dateFormat.format(item.expiresAt!)})';
    }
  }
}

import 'package:flutter/material.dart';
import '../../domain/entities/inventory_item.dart';

class AddInventoryDialog extends StatefulWidget {
  final Function(InventoryItem) onAdd;

  const AddInventoryDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddInventoryDialog> createState() => _AddInventoryDialogState();
}

class _AddInventoryDialogState extends State<AddInventoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedCategory;
  DateTime? _expiryDate;

  final List<String> _categories = [
    '野菜',
    '果物',
    '肉類',
    '魚介類',
    '乳製品',
    '調味料',
    'その他',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('食材を追加'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '食材名',
                  hintText: '例: にんじん',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '食材名を入力してください';
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'カテゴリ',
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _expiryDate == null
                      ? '有効期限（オプション）'
                      : '有効期限: ${_expiryDate!.year}/${_expiryDate!.month}/${_expiryDate!.day}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_expiryDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _expiryDate = null;
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectExpiryDate,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _addItem,
          child: const Text('追加'),
        ),
      ],
    );
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _expiryDate = date;
      });
    }
  }

  void _addItem() {
    if (_formKey.currentState!.validate()) {
      final item = InventoryItem(
        name: _nameController.text,
        addedAt: DateTime.now(),
        expiresAt: _expiryDate,
        category: _selectedCategory,
      );

      widget.onAdd(item);
      Navigator.of(context).pop();
    }
  }
}

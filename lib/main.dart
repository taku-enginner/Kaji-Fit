import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'shared/providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja');
  runApp(const ProviderScope(child: KajiFitApp()));
}

class KajiFitApp extends ConsumerWidget {
  const KajiFitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // データベースの初期化を待つ
    final databaseAsync = ref.watch(databaseProvider);

    return databaseAsync.when(
      data: (_) => MaterialApp.router(
        title: 'Kaji-Fit',
        theme: AppTheme.lightTheme,
        routerConfig: goRouter,
        debugShowCheckedModeBanner: false,
      ),
      loading: () => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Kaji-Fit',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('エラーが発生しました: $error'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

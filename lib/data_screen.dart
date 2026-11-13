import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app_settings.dart';
import 'models/settings_model.dart';
import 'models/transactions_model.dart';
import 'models/transaction_backup.dart';
import 'widgets/backup_import_dialog.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});
  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  bool _busy = false;

  Future<void> _export() async {
    final s = AppSettings.of(context);
    final model = context.read<TransactionsModel>();
    final json = const JsonEncoder.withIndent('  ').convert({
      'format': 'moneymate-transactions',
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'displayCurrency': context.read<SettingsModel>().currency,
      'transactions': model.transactions.map((item) => item.toJson()).toList(),
    });
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.text('Export transactions')),
        content: Text(
          s.text(
            'Copies all transaction details, including amounts, to your clipboard. Profile and budget are not included. Keep the copy somewhere private.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.text('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.text('Copy JSON')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(
      () => Clipboard.setData(ClipboardData(text: json)),
      'Transactions copied',
    );
  }

  Future<void> _import() async {
    final backup = await showDialog<TransactionBackup>(
      context: context,
      builder: (_) => const BackupImportDialog(),
    );
    if (backup == null || !mounted) return;
    final s = AppSettings.of(context);
    final currency = context.read<SettingsModel>().currency;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.text('Replace transactions?')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s
                    .text('Transactions in backup: {count}')
                    .replaceAll('{count}', '${backup.transactions.length}'),
              ),
              const SizedBox(height: 12),
              Text(
                s.text(
                  'This replaces all current transactions. Export them first if you need a copy. Profile, avatar, settings and budgets stay unchanged.',
                ),
              ),
              if (currency != backup.currency) ...[
                const SizedBox(height: 12),
                Text(
                  s
                      .text(
                        'Backup currency: {backup}. Current currency: {current}. Amounts will not be converted.',
                      )
                      .replaceAll('{backup}', backup.currency)
                      .replaceAll('{current}', currency),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.text('Cancel')),
          ),
          FilledButton(
            key: const ValueKey('confirm-restore'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.text('Replace and restore')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final model = context.read<TransactionsModel>();
    await _run(() => model.restore(backup), 'Transactions restored');
  }

  Future<void> _clear() async {
    final s = AppSettings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.text('Delete all transactions?')),
        content: Text(
          s.text(
            'This permanently removes all transactions from this device. Your profile, settings and budgets stay. Export your transactions first if you need a copy.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.text('Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              s.text('Delete all'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(context.read<TransactionsModel>().clear, 'Transactions deleted');
  }

  Future<void> _run(Future<void> Function() action, String message) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) _message(message);
    } catch (_) {
      if (mounted) _message('Could not save. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppSettings.of(context).text(message))),
  );

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.of(context);
    final count = context.watch<TransactionsModel>().transactions.length;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(s.text('Your data'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.storage_rounded, color: colors.primary, size: 32),
                  const SizedBox(height: 16),
                  Text(
                    '$count',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  Text(s.text('Transactions on this device')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(Icons.ios_share_rounded, color: colors.primary),
              title: Text(s.text('Export transactions')),
              subtitle: Text(s.text('Copy a JSON record of your transactions')),
              trailing: const Icon(Icons.chevron_right),
              onTap: _busy || count == 0 ? null : _export,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            s.text(
              'Save the exported text somewhere safe. You can paste it here to restore transactions on another device. Profile, avatar, settings and budgets are not included.',
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const ValueKey('import-backup'),
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(Icons.restore_rounded, color: colors.primary),
              title: Text(s.text('Restore transactions')),
              subtitle: Text(s.text('Paste a MoneyMate backup')),
              trailing: const Icon(Icons.chevron_right),
              onTap: _busy ? null : _import,
            ),
          ),
          const SizedBox(height: 28),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(Icons.delete_outline_rounded, color: colors.error),
              title: Text(
                s.text('Delete all transactions'),
                style: TextStyle(color: colors.error),
              ),
              subtitle: Text(s.text('This action cannot be undone')),
              onTap: _busy || count == 0 ? null : _clear,
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(20),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

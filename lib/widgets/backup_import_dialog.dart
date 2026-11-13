import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_settings.dart';
import '../models/transaction_backup.dart';

class BackupImportDialog extends StatefulWidget {
  const BackupImportDialog({super.key});
  @override
  State<BackupImportDialog> createState() => _BackupImportDialogState();
}

class _BackupImportDialogState extends State<BackupImportDialog> {
  final _controller = TextEditingController();
  String? _error;
  bool _pasting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    setState(() => _pasting = true);
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (!mounted) return;
      final text = data?.text ?? '';
      if (text.length > TransactionBackup.maxCharacters) {
        setState(
          () => _error =
              'Backup is too large. Maximum: 5 MB and 10,000 transactions.',
        );
        return;
      }
      _controller.text = text;
      setState(() => _error = text.isEmpty ? 'Clipboard is empty.' : null);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not read clipboard. Paste the backup manually.',
        );
      }
    } finally {
      if (mounted) setState(() => _pasting = false);
    }
  }

  void _validate() {
    try {
      final backup = TransactionBackup.parse(_controller.text);
      Navigator.pop(context, backup);
    } on FormatException {
      setState(
        () => _error =
            'Invalid or unsupported MoneyMate backup. Nothing has been changed.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.of(context);
    return AlertDialog(
      title: Text(s.text('Restore transactions')),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.text(
                  'Paste the complete text created by Export transactions.',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('backup-json'),
                controller: _controller,
                minLines: 3,
                maxLines: 6,
                maxLength: TransactionBackup.maxCharacters,
                decoration: InputDecoration(
                  labelText: s.text('Backup text'),
                  counterText: '',
                ),
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              TextButton.icon(
                onPressed: _pasting ? null : _paste,
                icon: const Icon(Icons.content_paste),
                label: Text(s.text('Paste from clipboard')),
              ),
              if (_error != null)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    s.text(_error!),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.text('Cancel')),
        ),
        FilledButton(
          key: const ValueKey('review-backup'),
          onPressed: _pasting ? null : _validate,
          child: Text(s.text('Review backup')),
        ),
      ],
    );
  }
}

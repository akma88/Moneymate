import 'dart:convert';
import 'transaction.dart';
import 'settings_model.dart';

/// The version 1 format is compatible with existing MoneyMate exports.
class TransactionBackup {
  TransactionBackup._(this.transactions, this.currency);
  final List<Transaction> transactions;
  final String currency;
  static const maxCharacters = 5 * 1024 * 1024;
  static const maxTransactions = 10000;

  factory TransactionBackup.parse(String source) {
    if (source.length > maxCharacters ||
        utf8.encode(source).length > maxCharacters) {
      throw const FormatException('Backup is too large');
    }
    try {
      final data = jsonDecode(source);
      if (data is! Map<String, dynamic> ||
          data['format'] != 'moneymate-transactions' ||
          data['version'] != 1 ||
          !SettingsModel.currencies.containsKey(data['displayCurrency']) ||
          data['transactions'] is! List) {
        throw const FormatException('Unsupported backup');
      }
      final entries = data['transactions'] as List;
      if (entries.length > maxTransactions) {
        throw const FormatException('Too many transactions');
      }
      final items = <Transaction>[];
      var total = 0.0;
      for (final entry in entries) {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException('Invalid transaction');
        }
        for (final key in ['title', 'category']) {
          final value = entry[key];
          if (value is! String || value.trim().isEmpty) {
            throw const FormatException('Invalid text');
          }
        }
        final rawDate = entry['date'];
        // DateTime.parse alone accepts invalid dates such as February 31.
        final match = rawDate is String
            ? RegExp(
                r'^(\d{4})-(\d{2})-(\d{2})T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?(?:Z|[+-]\d{2}:\d{2})?$',
              ).firstMatch(rawDate)
            : null;
        if (match == null) throw const FormatException('Invalid date');
        final year = int.parse(match[1]!);
        final month = int.parse(match[2]!);
        final day = int.parse(match[3]!);
        final calendar = DateTime(year, month, day);
        if (year < 1 ||
            calendar.year != year ||
            calendar.month != month ||
            calendar.day != day ||
            int.parse(rawDate.substring(11, 13)) > 23 ||
            int.parse(rawDate.substring(14, 16)) > 59 ||
            int.parse(rawDate.substring(17, 19)) > 59) {
          throw const FormatException('Invalid date');
        }
        final item = Transaction.fromJson(entry);
        total += item.amount;
        if (!total.isFinite) throw const FormatException('Amounts overflow');
        items.add(item);
      }
      return TransactionBackup._(
        List.unmodifiable(items),
        data['displayCurrency'] as String,
      );
    } on TypeError {
      throw const FormatException('Invalid backup fields');
    }
  }
}

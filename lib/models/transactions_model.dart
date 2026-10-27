import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'transaction.dart';


class TransactionsModel extends ChangeNotifier {
  TransactionsModel([this._preferences]) {
    for (final entry
        in _preferences?.getStringList('transactions') ?? <String>[]) {
      try {
        _transactions.add(
          Transaction.fromJson(jsonDecode(entry) as Map<String, dynamic>),
        );
      } on FormatException {
       
      } on TypeError {
        
      }
    }
  }

  final SharedPreferences? _preferences;
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => List.unmodifiable(
    [..._transactions]..sort((a, b) => b.date.compareTo(a.date)),
  );
  double get totalIncome => _total(true);
  double get totalExpenses => _total(false);
  double get balance => totalIncome - totalExpenses;

  
  double _total(bool isIncome) {
    double total = 0;
    for (final transaction in _transactions) {
      if (transaction.isIncome == isIncome) {
        total += transaction.amount;
      }
    }
    return total;
  }

  List<Transaction> search({
    String query = '',
    String? category,
    DateTime? from,
    DateTime? to,
  }) {
    final normalized = query.trim().toLowerCase();
    final end = to == null ? null : DateTime(to.year, to.month, to.day + 1);
    final start = from == null
        ? null
        : DateTime(from.year, from.month, from.day);
    return transactions
        .where(
          (item) =>
              item.title.toLowerCase().contains(normalized) &&
              (category == null || item.category == category) &&
              (start == null || !item.date.isBefore(start)) &&
              (end == null || item.date.isBefore(end)),
        )
        .toList();
  }

  Map<String, double> expensesByCategory(DateTime month) {
    final totals = <String, double>{};
    for (final item in _transactions) {
      if (!item.isIncome &&
          item.date.year == month.year &&
          item.date.month == month.month) {
        final previousAmount = totals[item.category] ?? 0;
        totals[item.category] = previousAmount + item.amount;
      }
    }
    return totals;
  }

  double expensesFor(DateTime month) {
    double total = 0;
    for (final amount in expensesByCategory(month).values) {
      total += amount;
    }
    return total;
  }

  Future<void> _pending = Future.value();

  Future<void> add(Transaction transaction) => _change(() {
    if (!transaction.amount.isFinite || transaction.amount <= 0) {
      throw ArgumentError.value(transaction.amount, 'amount');
    }
    return [..._transactions, transaction];
  });

  Future<void> remove(Transaction transaction) =>
      _change(() => [..._transactions]..remove(transaction));

  Future<void> update(Transaction original, Transaction replacement) =>
      _change(() {
        if (!replacement.amount.isFinite || replacement.amount <= 0) {
          throw ArgumentError.value(replacement.amount, 'amount');
        }
        return _transactions
            .map((item) => identical(item, original) ? replacement : item)
            .toList();
      });

  Future<void> _change(List<Transaction> Function() change) {
    final operation = _pending.then((_) async {
      final updated = change();
      final saved = await _preferences?.setStringList(
        'transactions',
        updated.map((item) => jsonEncode(item.toJson())).toList(),
      );
      if (saved == false) throw StateError('Could not save transactions');
      _transactions
        ..clear()
        ..addAll(updated);
      notifyListeners();
    });
    _pending = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return operation;
  }
}

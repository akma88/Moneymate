import 'package:flutter/foundation.dart';
import 'transaction.dart';

/// Provider owns the shared transaction list and notifies the dashboard.
class TransactionsModel extends ChangeNotifier {
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  double get totalIncome => _total(true);
  double get totalExpenses => _total(false);
  double get balance => totalIncome - totalExpenses;

  double _total(bool isIncome) => _transactions
      .where((transaction) => transaction.isIncome == isIncome)
      .fold(0.0, (total, transaction) => total + transaction.amount);

  void add(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }
}

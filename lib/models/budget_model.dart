import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetModel extends ChangeNotifier {
  BudgetModel([this._preferences]);
  final SharedPreferences? _preferences;
  final Map<String, double> _limits = {};

  String _key(DateTime month) => 'budget_${month.year}_${month.month}';
  double? limitFor(DateTime month) =>
      _limits[_key(month)] ?? _preferences?.getDouble(_key(month));

  Future<void> setLimit(DateTime month, double amount) async {
    if (!amount.isFinite || amount <= 0) throw ArgumentError.value(amount);
    final saved = await _preferences?.setDouble(_key(month), amount);
    if (saved == false) throw StateError('Could not save budget');
    _limits[_key(month)] = amount;
    notifyListeners();
  }
}

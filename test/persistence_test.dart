import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moneymate/models/transaction.dart';
import 'package:moneymate/models/transactions_model.dart';
import 'package:moneymate/models/user_model.dart';

Transaction entry(String title, double amount, bool income) => Transaction(
  title: title,
  amount: amount,
  category: 'Other',
  isIncome: income,
  date: DateTime(2026, 10, 19),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Concurrent writes, edits and deletion survive restart', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final model = TransactionsModel(preferences);
    final salary = entry('Salary', 100, true);
    final lunch = entry('Lunch', 25, false);
    await Future.wait([model.add(salary), model.add(lunch)]);
    expect(TransactionsModel(preferences).balance, 75);
    await model.update(lunch, entry('Lunch', 30, false));
    expect(TransactionsModel(preferences).balance, 70);
    await model.remove(salary);
    expect(TransactionsModel(preferences).balance, -30);
    await UserModel(preferences).register('  Aruzhan  ');
    expect(UserModel(preferences).name, 'Aruzhan');
  });

  test('Damaged entries do not hide valid saved transactions', () async {
    SharedPreferences.setMockInitialValues({
      'transactions': [
        'broken',
        '{}',
        jsonEncode(entry('Salary', 100, true).toJson()),
      ],
    });
    final model = TransactionsModel(await SharedPreferences.getInstance());
    expect(model.transactions.single.title, 'Salary');
    expect(model.balance, 100);
    await expectLater(
      model.add(entry('Invalid', double.infinity, false)),
      throwsArgumentError,
    );
    expect(model.balance, 100);
  });
}

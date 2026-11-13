import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moneymate/main.dart';
import 'package:moneymate/models/transaction.dart';
import 'package:moneymate/models/transaction_backup.dart';
import 'package:moneymate/models/transactions_model.dart';

Map<String, dynamic> backupData() => {
  'format': 'moneymate-transactions',
  'version': 1,
  'displayCurrency': 'USD',
  'transactions': [
    Transaction(
      title: 'Salary',
      amount: 1000,
      category: 'Salary',
      isIncome: true,
      date: DateTime(2026, 11, 1),
    ).toJson(),
    Transaction(
      title: 'Lunch',
      amount: 20,
      category: 'Food',
      isIncome: false,
      date: DateTime(2026, 11, 2),
    ).toJson(),
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Restore replaces, persists and is repeatable without duplicates',
    () async {
      SharedPreferences.setMockInitialValues({
        'budget_2026_11': 500.0,
        'profile_avatar': 'Fox',
      });
      final prefs = await SharedPreferences.getInstance();
      final model = TransactionsModel(prefs);
      await model.add(
        Transaction(
          title: 'Old',
          amount: 3,
          category: 'Food',
          isIncome: false,
          date: DateTime(2026),
        ),
      );
      final backup = TransactionBackup.parse(jsonEncode(backupData()));
      await model.restore(backup);
      await model.restore(backup);
      expect(model.transactions.length, 2);
      expect(model.balance, 980);
      expect(TransactionsModel(prefs).balance, 980);
      expect(prefs.getDouble('budget_2026_11'), 500);
      expect(prefs.getString('profile_avatar'), 'Fox');
    },
  );

  test(
    'Reject malformed, unsupported, oversized and partially invalid backups',
    () {
      for (final source in [
        '[]',
        '{}',
        'not json',
        '{',
        ' ' * (TransactionBackup.maxCharacters + 1),
      ]) {
        expect(() => TransactionBackup.parse(source), throwsFormatException);
      }
      for (final field in [
        'format',
        'version',
        'displayCurrency',
        'transactions',
      ]) {
        final data = backupData()..[field] = 'invalid';
        expect(
          () => TransactionBackup.parse(jsonEncode(data)),
          throwsFormatException,
        );
      }
      for (final change in [
        {'amount': -1},
        {'amount': 0},
        {'amount': '20'},
        {'amount': null},
        {'title': ''},
        {'isIncome': 'true'},
        {'category': null},
        {'date': '2026-02-31T12:00:00.000'},
        {'date': '2026-01-01T25:00:00'},
      ]) {
        final data = backupData();
        (data['transactions'] as List).last.addAll(change);
        expect(
          () => TransactionBackup.parse(jsonEncode(data)),
          throwsFormatException,
        );
      }
    },
  );

  test('Empty backup can explicitly replace all transactions', () async {
    final data = backupData()..['transactions'] = [];
    final model = TransactionsModel();
    await model.restore(TransactionBackup.parse(jsonEncode(backupData())));
    await model.restore(TransactionBackup.parse(jsonEncode(data)));
    expect(model.transactions, isEmpty);
  });

  testWidgets(
    'Import previews, cancellation preserves data, confirmation restores',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.binding.setSurfaceSize(const Size(320, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MoneyMateApp(preferences: prefs));
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Your data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Your data'));
      await tester.pumpAndSettle();
      Future<void> preview() async {
        await tester.ensureVisible(find.byKey(const ValueKey('import-backup')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('import-backup')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('backup-json')),
          jsonEncode(backupData()),
        );
        await tester.tap(find.byKey(const ValueKey('review-backup')));
        await tester.pumpAndSettle();
      }

      await preview();
      expect(find.text('Transactions in backup: 2'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(prefs.getStringList('transactions'), isNull);
      await preview();
      await tester.tap(find.byKey(const ValueKey('confirm-restore')));
      await tester.pumpAndSettle();
      expect(TransactionsModel(prefs).balance, 980);
      expect(find.text('Transactions restored'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

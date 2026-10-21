import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moneymate/main.dart';
import 'package:moneymate/home_screen.dart';
import 'package:moneymate/history_screen.dart';
import 'package:moneymate/models/budget_model.dart';
import 'package:moneymate/models/transaction.dart';
import 'package:moneymate/models/transactions_model.dart';
import 'package:moneymate/models/user_model.dart';

Transaction tx(
  String title,
  double amount,
  String category,
  DateTime date, {
  bool income = false,
}) => Transaction(
  title: title,
  amount: amount,
  category: category,
  isIncome: income,
  date: date,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Monthly totals exclude income and other months; filters combine inclusively',
    () async {
      final model = TransactionsModel();
      await model.add(tx('Lunch', 25, 'Food', DateTime(2026, 10, 19, 23, 59)));
      await model.add(tx('Lunch old', 10, 'Food', DateTime(2026, 9, 19)));
      await model.add(tx('Taxi', 15, 'Transport', DateTime(2026, 10, 19)));
      await model.add(
        tx('Salary', 100, 'Other', DateTime(2026, 10, 1), income: true),
      );
      expect(model.expensesByCategory(DateTime(2026, 10)), {
        'Food': 25,
        'Transport': 15,
      });
      expect(model.expensesFor(DateTime(2026, 10)), 40);
      expect(model.expensesFor(DateTime(2027, 10)), 0);
      expect(
        model
            .search(
              query: ' LUNCH ',
              category: 'Food',
              from: DateTime(2026, 10, 19),
              to: DateTime(2026, 10, 19),
            )
            .single
            .amount,
        25,
      );
      expect(model.search(query: 'Taxi', category: 'Food'), isEmpty);
    },
  );

  test(
    'Budget is persisted per month and logout stays logged out after restart',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final budget = BudgetModel(prefs);
      await budget.setLimit(DateTime(2026, 10), 1000);
      await budget.setLimit(DateTime(2026, 11), 2000);
      expect(BudgetModel(prefs).limitFor(DateTime(2026, 10)), 1000);
      expect(BudgetModel(prefs).limitFor(DateTime(2026, 11)), 2000);
      expect(BudgetModel(prefs).limitFor(DateTime(2027, 10)), isNull);
      await expectLater(
        budget.setLimit(DateTime(2026, 10), double.nan),
        throwsArgumentError,
      );
      final user = UserModel(prefs);
      await user.register(' Aruzhan ', email: ' test@example.com ');
      expect(UserModel(prefs).email, 'test@example.com');
      await user.signOut();
      expect(UserModel(prefs).isSignedIn, false);
      expect(UserModel(prefs).name, isNull);
    },
  );

  testWidgets('History search, category and reset work on a phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MoneyMateApp());
    final model = tester
        .element(find.byType(HomeScreen))
        .read<TransactionsModel>();
    await model.add(tx('Lunch', 25, 'Food', DateTime.now()));
    await model.add(tx('Taxi', 15, 'Transport', DateTime.now()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('history-search')),
      'lunch',
    );
    await tester.pumpAndSettle();
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Taxi'), findsNothing);
    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    expect(find.text('Taxi'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transport').last);
    await tester.pumpAndSettle();
    expect(find.text('Lunch'), findsNothing);
    expect(find.text('Taxi'), findsOneWidget);
  });

  testWidgets('Budget save and overspend; statistics reflect expenses', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MoneyMateApp());
    final model = tester
        .element(find.byType(HomeScreen))
        .read<TransactionsModel>();
    await model.add(tx('Lunch', 125, 'Food', DateTime.now()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Budget'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('budget-limit')),
      '100,00',
    );
    await tester.tap(find.text('Save budget'));
    await tester.pumpAndSettle();
    expect(find.text('Over budget'), findsOneWidget);
    expect(find.text(r'$25.00'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Statistics'));
    await tester.pumpAndSettle();
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('100.0%'), findsOneWidget);
  });

  testWidgets(
    'Profile validates email, saves and signs out without deleting operations',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MoneyMateApp());
      final context = tester.element(find.byType(HomeScreen));
      final finances = context.read<TransactionsModel>();
      await finances.add(tx('Lunch', 25, 'Food', DateTime.now()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create a profile'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('profile-name')),
        'Aruzhan',
      );
      await tester.enterText(
        find.byKey(const ValueKey('profile-email')),
        'invalid',
      );
      await tester.tap(find.text('Save profile'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('profile-email')),
        'test@example.com',
      );
      await tester.tap(find.text('Save profile'));
      await tester.pumpAndSettle();
      expect(find.text('test@example.com'), findsOneWidget);
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out').last);
      await tester.pumpAndSettle();
      expect(ScopedModel.of<UserModel>(context).isSignedIn, false);
      expect(finances.transactions.single.title, 'Lunch');
    },
  );
}

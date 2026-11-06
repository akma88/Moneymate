import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/add_transaction_screen.dart';
import 'package:moneymate/app_settings.dart';
import 'package:moneymate/models/transaction.dart';

void main() {
  testWidgets('Income has its own sources and saves the selected source', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(600, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Transaction? saved;
    await tester.pumpWidget(
      AppSettings(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  saved = await Navigator.of(context).push<Transaction>(
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen(),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    expect(find.text('Income source'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(find.text('Food'), findsNothing);
    await tester.tap(find.text('Freelance').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expense'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .initialValue,
      'Food',
    );
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .initialValue,
      'Freelance',
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'Design work');
    await tester.enterText(find.byType(TextFormField).at(1), '15000');
    await tester.ensureVisible(find.text('Save Income'));
    await tester.tap(find.text('Save Income'));
    await tester.pumpAndSettle();
    expect(saved?.isIncome, true);
    expect(saved?.category, 'Freelance');
    expect(saved?.amount, 15000);
  });

  testWidgets('Legacy income category remains editable', (tester) async {
    await tester.pumpWidget(
      AppSettings(
        child: MaterialApp(
          home: AddTransactionScreen(
            transaction: Transaction(
              title: 'Old income',
              amount: 100,
              category: 'Food',
              isIncome: true,
              date: DateTime(2026, 1, 1),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .initialValue,
      'Food',
    );
  });
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moneymate/models/settings_model.dart';
import 'package:moneymate/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:moneymate/main.dart';
import 'package:moneymate/home_screen.dart';
import 'package:moneymate/models/transaction.dart';
import 'package:moneymate/models/transactions_model.dart';
import 'package:moneymate/models/user_model.dart';

void main() {
  testWidgets('Shared models update the dashboard', (tester) async {
    await tester.pumpWidget(const MoneyMateApp());
    expect(find.text('Good morning 👋'), findsOneWidget);
    expect(find.text('No transactions yet'), findsOneWidget);

    final context = tester.element(find.byType(HomeScreen));
    ScopedModel.of<UserModel>(context).register('Aruzhan');
    context.read<TransactionsModel>().add(
      Transaction(
        title: 'Salary',
        amount: 100,
        category: 'Other',
        isIncome: true,
        date: DateTime(2026, 10, 12),
      ),
    );
    context.read<TransactionsModel>().add(
      Transaction(
        title: 'Lunch',
        amount: 25,
        category: 'Food',
        isIncome: false,
        date: DateTime(2026, 10, 12),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Aruzhan 👋'), findsOneWidget);
    expect(find.text(r'$75.00'), findsOneWidget);
    expect(find.text(r'$100.00'), findsOneWidget);
    expect(find.text(r'$25.00'), findsOneWidget);
    expect(find.text('No transactions yet'), findsNothing);
  });

  testWidgets('setState toggles transaction type', (tester) async {
    await tester.pumpWidget(const MoneyMateApp());
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('No transactions yet'), findsOneWidget);
  });
  testWidgets('Settings controls update app and persist selection', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(MoneyMateApp(preferences: preferences));
    final homeContext = tester.element(find.byType(HomeScreen));
    ScopedModel.of<UserModel>(homeContext).register('Aruzhan');
    homeContext.read<TransactionsModel>().add(
      Transaction(
        title: 'Salary',
        amount: 100,
        category: 'Other',
        isIncome: true,
        date: DateTime(2026, 10, 12),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('currency-USD')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('KZT (₸)').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('theme-system')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(SettingsScreen))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.byKey(const ValueKey('language-en')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский').last);
    await tester.pumpAndSettle();
    expect(find.text('Настройки'), findsOneWidget);
    expect(find.text('Валюта'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Доброе утро, Aruzhan 👋'), findsOneWidget);
    expect(find.text('₸100.00'), findsNWidgets(2));
    expect(
      homeContext.read<TransactionsModel>().transactions.single.amount,
      100,
    );
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Добавить операцию'), findsOneWidget);
    expect(find.text('Еда'), findsOneWidget);
    await tester.ensureVisible(find.byIcon(Icons.calendar_month));
    await tester.tap(find.byIcon(Icons.calendar_month));
    await tester.pumpAndSettle();
    expect(
      Localizations.localeOf(
        tester.element(find.byType(DatePickerDialog)),
      ).languageCode,
      'ru',
    );
    final dialogContext = tester.element(find.byType(DatePickerDialog));
    await tester.tap(
      find.text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(MoneyMateApp(preferences: preferences));
    await tester.pumpAndSettle();
    final restored = tester
        .element(find.byType(HomeScreen))
        .read<SettingsModel>();
    expect(restored.currency, 'KZT');
    expect(restored.language, 'ru');
    expect(restored.themeMode, ThemeMode.dark);
    await restored.setLanguage('kk');
    await tester.pumpAndSettle();
    expect(find.text('Жалпы баланс'), findsOneWidget);
  });

  test('Invalid saved settings use supported defaults', () async {
    SharedPreferences.setMockInitialValues({
      'currency': 'invalid',
      'language': 'invalid',
      'theme': 'invalid',
    });
    final settings = SettingsModel(await SharedPreferences.getInstance());
    expect(settings.currency, 'USD');
    expect(settings.language, 'en');
    expect(settings.themeMode, ThemeMode.system);
  });
}

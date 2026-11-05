import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moneymate/main.dart';
import 'package:moneymate/profile_screen.dart';
import 'package:moneymate/security_screen.dart';
import 'package:moneymate/data_screen.dart';
import 'package:moneymate/settings_screen.dart';
import 'package:moneymate/home_screen.dart';
import 'package:moneymate/app_settings.dart';
import 'package:moneymate/models/settings_model.dart';
import 'package:moneymate/models/transaction.dart';
import 'package:moneymate/models/transactions_model.dart';
import 'package:moneymate/models/budget_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Privacy preferences survive restart', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsModel(prefs);
    expect(settings.privacyScreen, isTrue);
    await settings.setHideAmounts(true);
    await settings.setPrivacyScreen(false);
    final restored = SettingsModel(prefs);
    expect(restored.hideAmounts, isTrue);
    expect(restored.privacyScreen, isFalse);
  });

  testWidgets('Privacy masks amounts and covers inactive app', (tester) async {
    await tester.pumpWidget(const MoneyMateApp());
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(HomeScreen));
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Security & privacy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Security & privacy'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hide-amounts')));
    await tester.pumpAndSettle();
    expect(context.read<SettingsModel>().hideAmounts, isTrue);
    expect(AppSettings.of(context).formatMoney(123), '••••');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('privacy-cover')), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('privacy-cover')), findsNothing);
    await context.read<SettingsModel>().setPrivacyScreen(false);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('privacy-cover')), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Export requires consent; clearing preserves budget and persists',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(MoneyMateApp(preferences: prefs));
      final context = tester.element(find.byType(HomeScreen));
      final model = context.read<TransactionsModel>();
      await model.add(
        Transaction(
          title: 'Lunch',
          amount: 25,
          category: 'Food',
          isIncome: false,
          date: DateTime(2026, 11, 5),
        ),
      );
      await context.read<BudgetModel>().setLimit(DateTime(2026, 11), 100);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Your data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Your data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export transactions'));
      await tester.pumpAndSettle();
      expect(copied, isNull);
      await tester.tap(find.text('Copy JSON'));
      await tester.pumpAndSettle();
      final exported = jsonDecode(copied!) as Map<String, dynamic>;
      expect((exported['transactions'] as List).single['amount'], 25);
      await tester.ensureVisible(find.text('Delete all transactions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete all transactions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(model.transactions, hasLength(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete all transactions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete all'));
      await tester.pumpAndSettle();
      expect(model.transactions, isEmpty);
      expect(TransactionsModel(prefs).transactions, isEmpty);
      expect(BudgetModel(prefs).limitFor(DateTime(2026, 11)), 100);
    },
  );
  testWidgets('Profile screens fit narrow phones in all languages', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MoneyMateApp());
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(HomeScreen));
    final settings = context.read<SettingsModel>();
    for (final language in ['en', 'ru', 'kk']) {
      await settings.setLanguage(language);
      for (final theme in [ThemeMode.light, ThemeMode.dark]) {
        await settings.setTheme(theme);
        await tester.pumpAndSettle();
        for (final screen in [
          const ProfileScreen(),
          const SecurityScreen(),
          const DataScreen(),
          const SettingsScreen(),
        ]) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => screen));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.drag(find.byType(ListView).last, const Offset(0, -500));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          Navigator.of(context).pop();
          await tester.pumpAndSettle();
        }
      }
    }
  });
  testWidgets('Dashboard reveals hidden amounts and persists the choice', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'hide_amounts': true});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(MoneyMateApp(preferences: prefs));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Show amounts'), findsOneWidget);
    expect(find.text(r'$0.00'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('toggle-amount-visibility')));
    await tester.pumpAndSettle();
    expect(find.text(r'$0.00'), findsNWidgets(3));
    expect(SettingsModel(prefs).hideAmounts, isFalse);
    await tester.tap(find.byTooltip('Hide amounts'));
    await tester.pumpAndSettle();
    expect(find.text(r'$0.00'), findsNothing);
    expect(SettingsModel(prefs).hideAmounts, isTrue);
  });
}

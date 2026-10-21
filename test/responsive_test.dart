import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/main.dart';
import 'package:moneymate/home_screen.dart';
import 'package:moneymate/models/settings_model.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Dashboard fits a narrow phone in each language and theme', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const MoneyMateApp());
    await tester.pumpAndSettle();
    final settings = tester
        .element(find.byType(HomeScreen))
        .read<SettingsModel>();
    tester.view.physicalSize = const Size(320, 720);
    for (final language in ['en', 'ru', 'kk']) {
      await settings.setLanguage(language);
      for (final theme in [ThemeMode.light, ThemeMode.dark]) {
        await settings.setTheme(theme);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    }
  });
}

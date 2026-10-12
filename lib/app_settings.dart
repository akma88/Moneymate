import 'package:flutter/material.dart';
import 'app_strings.dart';

/// InheritedWidget provides shared formatting settings to descendant screens.
class AppSettings extends InheritedWidget {
  const AppSettings({
    super.key,
    this.currencySymbol = r'$',
    this.languageCode = 'en',
    required super.child,
  });

  final String currencySymbol;
  final String languageCode;

  String text(String source) =>
      appTranslations[languageCode]?[source] ?? source;

  String greeting(String? name) => name == null
      ? text('Good morning 👋')
      : text('Good morning, {name} 👋').replaceAll('{name}', name);

  static AppSettings of(BuildContext context) {
    final settings = context.dependOnInheritedWidgetOfExactType<AppSettings>();
    assert(settings != null, 'AppSettings is missing from the widget tree');
    return settings!;
  }

  String formatMoney(double amount) =>
      '$currencySymbol${amount.toStringAsFixed(2)}';

  @override
  bool updateShouldNotify(AppSettings oldWidget) =>
      currencySymbol != oldWidget.currencySymbol ||
      languageCode != oldWidget.languageCode;
}

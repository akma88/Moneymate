import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel([this._preferences]) {
    final currency = _preferences?.getString('currency');
    if (currencies.containsKey(currency)) _currency = currency!;
    final language = _preferences?.getString('language');
    if (languages.containsKey(language)) _language = language!;
    final theme = _preferences?.getString('theme');
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == theme,
      orElse: () => ThemeMode.system,
    );
  }

  static const currencies = {'USD': r'$', 'KZT': '₸', 'EUR': '€', 'RUB': '₽'};
  static const languages = {'en': 'English', 'ru': 'Русский', 'kk': 'Қазақша'};
  final SharedPreferences? _preferences;
  String _currency = 'USD';
  String _language = 'en';
  ThemeMode _themeMode = ThemeMode.system;

  String get currency => _currency;
  String get currencySymbol => currencies[_currency]!;
  String get language => _language;
  ThemeMode get themeMode => _themeMode;

  Future<void> setCurrency(String value) async {
    if (!currencies.containsKey(value) || value == _currency) return;
    _currency = value;
    notifyListeners();
    await _preferences?.setString('currency', value);
  }

  Future<void> setLanguage(String value) async {
    if (!languages.containsKey(value) || value == _language) return;
    _language = value;
    notifyListeners();
    await _preferences?.setString('language', value);
  }

  Future<void> setTheme(ThemeMode value) async {
    if (value == _themeMode) return;
    _themeMode = value;
    notifyListeners();
    await _preferences?.setString('theme', value.name);
  }
}

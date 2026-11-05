import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel([this._preferences]) {
    _hideAmounts = _preferences?.getBool('hide_amounts') ?? false;
    _privacyScreen = _preferences?.getBool('privacy_screen') ?? true;
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
  bool _hideAmounts = false;
  bool _privacyScreen = true;
  bool get hideAmounts => _hideAmounts;
  bool get privacyScreen => _privacyScreen;

  Future<void> setHideAmounts(bool value) async {
    final saved = await _preferences?.setBool('hide_amounts', value);
    if (saved == false) throw StateError('Could not save settings');
    _hideAmounts = value;
    notifyListeners();
  }

  Future<void> setPrivacyScreen(bool value) async {
    final saved = await _preferences?.setBool('privacy_screen', value);
    if (saved == false) throw StateError('Could not save settings');
    _privacyScreen = value;
    notifyListeners();
  }

  String _currency = 'USD';
  String _language = 'en';
  ThemeMode _themeMode = ThemeMode.system;

  String get currency => _currency;
  String get currencySymbol => currencies[_currency]!;
  String get language => _language;
  ThemeMode get themeMode => _themeMode;

  Future<void> setCurrency(String value) async {
    if (!currencies.containsKey(value) || value == _currency) return;
    final saved = await _preferences?.setString('currency', value);
    if (saved == false) throw StateError('Could not save settings');
    _currency = value;
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    if (!languages.containsKey(value) || value == _language) return;
    final saved = await _preferences?.setString('language', value);
    if (saved == false) throw StateError('Could not save settings');
    _language = value;
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode value) async {
    if (value == _themeMode) return;
    final saved = await _preferences?.setString('theme', value.name);
    if (saved == false) throw StateError('Could not save settings');
    _themeMode = value;
    notifyListeners();
  }
}

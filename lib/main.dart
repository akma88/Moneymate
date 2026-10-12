import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_settings.dart';
import 'home_screen.dart';
import 'models/settings_model.dart';
import 'models/transactions_model.dart';
import 'models/user_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(MoneyMateApp(preferences: preferences));
}

class MoneyMateApp extends StatefulWidget {
  const MoneyMateApp({super.key, this.preferences});
  final SharedPreferences? preferences;

  @override
  State<MoneyMateApp> createState() => _MoneyMateAppState();
}

class _MoneyMateAppState extends State<MoneyMateApp> {
  final _user = UserModel();

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D60),
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF5F8F6)
          : scheme.surface,
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionsModel()),
        ChangeNotifierProvider(
          create: (_) => SettingsModel(widget.preferences),
        ),
      ],
      child: ScopedModel<UserModel>(
        model: _user,
        child: Consumer<SettingsModel>(
          builder: (context, settings, child) => AppSettings(
            currencySymbol: settings.currencySymbol,
            languageCode: settings.language,
            child: MaterialApp(
              title: 'MoneyMate',
              debugShowCheckedModeBanner: false,
              theme: _theme(Brightness.light),
              darkTheme: _theme(Brightness.dark),
              themeMode: settings.themeMode,
              locale: Locale(settings.language),
              supportedLocales: const [
                Locale('en'),
                Locale('ru'),
                Locale('kk'),
              ],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              home: const HomeScreen(),
            ),
          ),
        ),
      ),
    );
  }
}

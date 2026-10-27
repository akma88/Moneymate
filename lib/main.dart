import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_settings.dart';
import 'app_theme.dart';
import 'home_screen.dart';
import 'models/settings_model.dart';
import 'models/budget_model.dart';
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
  late final _user = UserModel(widget.preferences);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BudgetModel(widget.preferences)),
        ChangeNotifierProvider(
          create: (_) => TransactionsModel(widget.preferences),
        ),
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
              theme: AppTheme.build(Brightness.light),
              darkTheme: AppTheme.build(Brightness.dark),
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

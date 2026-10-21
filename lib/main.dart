import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_settings.dart';
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

  ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF28705A),
      brightness: brightness,
      surface: isDark ? const Color(0xFF15221E) : const Color(0xFFFAFAF6),
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF20322B) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: isDark
            ? scheme.primaryContainer
            : const Color(0xFFE0EDC8),
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFD7EF9C),
        foregroundColor: Color(0xFF153E35),
        elevation: 2,
      ),
    );
  }

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

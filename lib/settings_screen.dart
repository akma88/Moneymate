import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_settings.dart';
import 'models/settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final strings = AppSettings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.text('Settings'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('currency-${settings.currency}'),
            initialValue: settings.currency,
            decoration: InputDecoration(
              labelText: strings.text('Currency'),
              prefixIcon: const Icon(Icons.payments_outlined),
              border: const OutlineInputBorder(),
            ),
            items: SettingsModel.currencies.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text('${entry.key} (${entry.value})'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) settings.setCurrency(value);
            },
          ),
          const SizedBox(height: 12),
          Text(
            strings.text(
              'Currency changes the symbol only, without conversion.',
            ),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<ThemeMode>(
            key: ValueKey('theme-${settings.themeMode.name}'),
            initialValue: settings.themeMode,
            decoration: InputDecoration(
              labelText: strings.text('Theme'),
              prefixIcon: const Icon(Icons.palette_outlined),
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text(strings.text('System')),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text(strings.text('Light')),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text(strings.text('Dark')),
              ),
            ],
            onChanged: (value) {
              if (value != null) settings.setTheme(value);
            },
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            key: ValueKey('language-${settings.language}'),
            initialValue: settings.language,
            decoration: InputDecoration(
              labelText: strings.text('Language'),
              prefixIcon: const Icon(Icons.language),
              border: const OutlineInputBorder(),
            ),
            items: SettingsModel.languages.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) settings.setLanguage(value);
            },
          ),
        ],
      ),
    );
  }
}

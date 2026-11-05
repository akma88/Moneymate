import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_settings.dart';
import 'models/settings_model.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});
  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _saving = false;
  Future<void> _save(Future<void> Function() action) async {
    setState(() => _saving = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppSettings.of(context).text('Could not save. Please try again.'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.of(context);
    final settings = context.watch<SettingsModel>();
    return Scaffold(
      appBar: AppBar(title: Text(s.text('Security & privacy'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.text('Privacy on your terms'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.text(
                      'This is a local profile, without a password or biometric lock. Use your device lock to restrict access.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  key: const ValueKey('hide-amounts'),
                  title: Text(s.text('Hide amounts')),
                  subtitle: Text(
                    s.text(
                      'Mask financial totals throughout the app. Entry fields and exports still show amounts.',
                    ),
                  ),
                  value: settings.hideAmounts,
                  onChanged: _saving
                      ? null
                      : (value) => _save(() => settings.setHideAmounts(value)),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  key: const ValueKey('privacy-screen'),
                  title: Text(s.text('Cover app in background')),
                  subtitle: Text(
                    s.text(
                      'Show a privacy cover when the app becomes inactive. This does not block screenshots or lock the app.',
                    ),
                  ),
                  value: settings.privacyScreen,
                  onChanged: _saving
                      ? null
                      : (value) =>
                            _save(() => settings.setPrivacyScreen(value)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.text('Data stays on this device'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            s.text(
              'No cloud sync or verified account. Local storage is not an encrypted vault. Removing the app may remove its data.',
            ),
          ),
        ],
      ),
    );
  }
}

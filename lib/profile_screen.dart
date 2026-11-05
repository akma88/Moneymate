import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'app_settings.dart';
import 'models/user_model.dart';
import 'models/settings_model.dart';
import 'registration_screen.dart';
import 'settings_screen.dart';
import 'security_screen.dart';
import 'data_screen.dart';
import 'widgets/profile_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _open(BuildContext context, Widget screen) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.of(context);
    final user = ScopedModel.of<UserModel>(context, rebuildOnChange: true);
    final settings = context.watch<SettingsModel>();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(s.text('Profile'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const ProfileAvatar(),
                      const SizedBox(height: 14),
                      Text(
                        user.name ?? s.text('Make it yours'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.email?.isNotEmpty == true
                            ? user.email!
                            : s.text('Local profile'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            _open(context, const RegistrationScreen()),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(
                          s.text(
                            user.isSignedIn
                                ? 'Edit profile'
                                : 'Create a profile',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                s.text('Preferences & data'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    _tile(
                      context,
                      Icons.tune_rounded,
                      s.text('Settings'),
                      '${SettingsModel.languages[settings.language]} · ${settings.currency} · ${s.text(switch (settings.themeMode) {
                        ThemeMode.light => 'Light',
                        ThemeMode.dark => 'Dark',
                        ThemeMode.system => 'System',
                      })}',
                      () => _open(context, const SettingsScreen()),
                    ),
                    const Divider(height: 1, indent: 66),
                    _tile(
                      context,
                      Icons.shield_outlined,
                      s.text('Security & privacy'),
                      s.text('Amount visibility and background cover'),
                      () => _open(context, const SecurityScreen()),
                    ),
                    const Divider(height: 1, indent: 66),
                    _tile(
                      context,
                      Icons.storage_outlined,
                      s.text('Your data'),
                      s.text('Export and manage your transactions'),
                      () => _open(context, const DataScreen()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (user.isSignedIn)
                OutlinedButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(s.text('Sign out?')),
                        content: Text(
                          s.text(
                            'Transactions and budget will stay on this device.',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(s.text('Cancel')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(s.text('Sign out')),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true || !context.mounted) return;
                    try {
                      await user.signOut();
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              s.text('Could not save. Please try again.'),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(s.text('Sign out')),
                ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.text('Local profile only. Email is not verified.'),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'MoneyMate',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: colors.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}

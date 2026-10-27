import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'app_settings.dart';
import 'models/user_model.dart';
import 'registration_screen.dart';
import 'widgets/coin_mascot.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.of(context);
    final user = ScopedModel.of<UserModel>(context, rebuildOnChange: true);
    return Scaffold(
      appBar: AppBar(title: Text(s.text('Profile'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: CoinMascot(size: 104)),
          const SizedBox(height: 24),
          if (user.isSignedIn) ...[
            ListTile(
              title: Text(s.text('Full Name')),
              subtitle: Text(user.name ?? ''),
            ),
            ListTile(
              title: Text(s.text('Email')),
              subtitle: Text(user.email ?? s.text('Not specified')),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const RegistrationScreen()),
            ),
            child: Text(
              s.text(user.isSignedIn ? 'Edit profile' : 'Create a profile'),
            ),
          ),
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
          const SizedBox(height: 16),
          Text(s.text('Local profile only. Email is not verified.')),
        ],
      ),
    );
  }
}

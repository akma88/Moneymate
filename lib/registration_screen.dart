import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'app_settings.dart';
import 'models/user_model.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ScopedModel.of<UserModel>(context);
    _name.text = user.name ?? '';
    _email.text = user.email ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ScopedModel.of<UserModel>(
        context,
      ).register(_name.text, email: _email.text);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppSettings.of(context).text('Could not save. Please try again.'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.text('Local profile'))),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.account_circle_outlined, size: 80),
            const SizedBox(height: 24),
            TextFormField(
              key: const ValueKey('profile-name'),
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: s.text('Full Name'),
                border: const OutlineInputBorder(),
              ),
              validator: (value) => (value?.trim().length ?? 0) < 2
                  ? s.text('Name must contain at least 2 characters')
                  : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const ValueKey('profile-email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: s.text('Email'),
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  !RegExp(
                    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                  ).hasMatch(value?.trim() ?? '')
                  ? s.text('Please enter a valid email')
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(s.text('Save profile')),
            ),
            const SizedBox(height: 16),
            Text(
              s.text(
                'Your profile and transactions are stored on this device.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'app_settings.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _nameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),

                Center(
                  child: Container(
                    width: 75,
                    height: 75,

                    decoration: BoxDecoration(
                      color: Color(0xFF2E7D60),
                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                SizedBox(height: 25),

                Center(
                  child: Text(
                    AppSettings.of(context).text('Create your account'),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),

                SizedBox(height: 8),

                Center(
                  child: Text(
                    AppSettings.of(
                      context,
                    ).text('Start managing your money with MoneyMate'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

                SizedBox(height: 35),

                Text(
                  AppSettings.of(context).text('Full Name'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 8),

                TextFormField(
                  controller: _nameController,

                  decoration: InputDecoration(
                    hintText: AppSettings.of(context).text('Enter your name'),
                    prefixIcon: Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLow,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Color(0xFF2E7D60),
                        width: 2,
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppSettings.of(
                        context,
                      ).text('Please enter your name');
                    }

                    if (value.trim().length < 2) {
                      return AppSettings.of(
                        context,
                      ).text('Name must contain at least 2 characters');
                    }

                    return null;
                  },
                ),

                SizedBox(height: 20),

                Text(
                  AppSettings.of(context).text('Email'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 8),

                TextFormField(
                  controller: _emailController,

                  keyboardType: TextInputType.emailAddress,

                  decoration: InputDecoration(
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLow,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Color(0xFF2E7D60),
                        width: 2,
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppSettings.of(
                        context,
                      ).text('Please enter your email');
                    }

                    if (!value.contains('@')) {
                      return AppSettings.of(
                        context,
                      ).text('Please enter a valid email');
                    }

                    return null;
                  },
                ),

                SizedBox(height: 20),

                Text(
                  AppSettings.of(context).text('Password'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 8),

                TextFormField(
                  controller: _passwordController,

                  obscureText: _hidePassword,

                  decoration: InputDecoration(
                    hintText: AppSettings.of(
                      context,
                    ).text('Enter your password'),

                    prefixIcon: Icon(Icons.lock_outline),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },

                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),

                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLow,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Color(0xFF2E7D60),
                        width: 2,
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppSettings.of(
                        context,
                      ).text('Please enter a password');
                    }

                    if (value.length < 6) {
                      return AppSettings.of(
                        context,
                      ).text('Password must contain at least 6 characters');
                    }

                    return null;
                  },
                ),

                SizedBox(height: 20),

                Text(
                  AppSettings.of(context).text('Confirm Password'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 8),

                TextFormField(
                  controller: _confirmPasswordController,

                  obscureText: _hideConfirmPassword,

                  decoration: InputDecoration(
                    hintText: AppSettings.of(
                      context,
                    ).text('Repeat your password'),

                    prefixIcon: Icon(Icons.lock_outline),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _hideConfirmPassword = !_hideConfirmPassword;
                        });
                      },

                      icon: Icon(
                        _hideConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),

                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLow,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Color(0xFF2E7D60),
                        width: 2,
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppSettings.of(
                        context,
                      ).text('Please confirm your password');
                    }

                    if (value != _passwordController.text) {
                      return AppSettings.of(
                        context,
                      ).text('Passwords do not match');
                    }

                    return null;
                  },
                ),

                SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: _register,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E7D60),
                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    child: Text(
                      AppSettings.of(context).text('Create Account'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Center(
                  child: Text(
                    AppSettings.of(context).text(
                      'By creating an account, you agree to use MoneyMate responsibly.',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

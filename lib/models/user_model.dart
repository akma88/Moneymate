import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {
  UserModel([this._preferences]) {
    final profile = _preferences?.getString('user_profile');
    if (profile != null) {
      try {
        final data = jsonDecode(profile) as Map<String, dynamic>;
        _name = data['name'] as String?;
        _email = data['email'] as String?;
        _active = data['active'] as bool? ?? false;
      } on FormatException {
       
      } on TypeError {
        _name = null;
        _email = null;
      }
    } else {
      _name = _preferences?.getString('user_name');
      _active = _name != null;
    }
  }

  final SharedPreferences? _preferences;
  String? _name;
  String? _email;
  bool _active = false;
  String? get name => _active ? _name : null;
  String? get email => _active ? _email : null;
  bool get isSignedIn => _active;

  Future<void> register(String name, {String? email}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _save(trimmed, email?.trim() ?? _email, true);
  }

  Future<void> signOut() => _save(_name, _email, false);

  Future<void> _save(String? name, String? email, bool active) async {
    final saved = await _preferences?.setString(
      'user_profile',
      jsonEncode({'name': name, 'email': email, 'active': active}),
    );
    if (saved == false) throw StateError('Could not save profile');
    _name = name;
    _email = email;
    _active = active;
    notifyListeners();
  }
}

import 'package:scoped_model/scoped_model.dart';

/// ScopedModel shares the registered user's name across screens.
class UserModel extends Model {
  String? _name;
  String? get name => _name;

  void register(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || trimmedName == _name) return;
    _name = trimmedName;
    notifyListeners();
  }
}

import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {
  UserModel([this._preferences]) {
    final avatar = _preferences?.getString('profile_avatar');
    if (avatars.containsKey(avatar)) _avatar = avatar;
    if (avatar != null && avatar.startsWith('photo:')) {
      try {
        final bytes = base64Decode(avatar.substring(6));
        if (bytes.length <= 300000) _avatarPhoto = bytes;
      } on FormatException {
        // A damaged saved image falls back to initials.
      }
    }
    final profile = _preferences?.getString('user_profile');
    if (profile != null) {
      try {
        final data = jsonDecode(profile) as Map<String, dynamic>;
        _name = data['name'] as String?;
        _email = data['email'] as String?;
        _active = data['active'] as bool? ?? false;
      } on FormatException {
        // Ignore an invalid saved profile and use the default local profile.
      } on TypeError {
        _name = null;
        _email = null;
      }
    } else {
      _name = _preferences?.getString('user_name');
      _active = _name != null;
    }
  }

  static const avatars = {
    'Cat': '🐱',
    'Fox': '🦊',
    'Panda': '🐼',
    'Koala': '🐨',
    'Lion': '🦁',
    'Penguin': '🐧',
    'Unicorn': '🦄',
    'Robot': '🤖',
  };
  Uint8List? _avatarPhoto;
  Uint8List? get avatarPhoto => _avatarPhoto;
  String? photoRecoveryError;

  Future<void> setAvatarPhoto(XFile file) async {
    // Bound input memory, then store only a small square thumbnail, without
    // the source photo's EXIF/location metadata or temporary picker path.
    if (await file.length() > 30 * 1024 * 1024) {
      throw const FormatException('Photo exceeds 30 MB');
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(
      await file.readAsBytes(),
    );
    final codec = await ui.instantiateImageCodecWithSize(
      buffer,
      getTargetSize: (width, height) {
        final longest = width > height ? width : height;
        final scale = longest > 512 ? 512 / longest : 1.0;
        return ui.TargetImageSize(
          width: (width * scale).round().clamp(1, 512),
          height: (height * scale).round().clamp(1, 512),
        );
      },
    );
    ui.Image? original;
    ui.Image? thumbnail;
    try {
      original = (await codec.getNextFrame()).image;
      final side = original.width < original.height
          ? original.width.toDouble()
          : original.height.toDouble();
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawImageRect(
        original,
        ui.Rect.fromLTWH(
          (original.width - side) / 2,
          (original.height - side) / 2,
          side,
          side,
        ),
        const ui.Rect.fromLTWH(0, 0, 256, 256),
        ui.Paint()..filterQuality = ui.FilterQuality.medium,
      );
      final picture = recorder.endRecording();
      try {
        thumbnail = await picture.toImage(256, 256);
      } finally {
        picture.dispose();
      }
      final data = await thumbnail.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Could not decode photo');
      final bytes = data.buffer.asUint8List();
      final saved = await _preferences?.setString(
        'profile_avatar',
        'photo:${base64Encode(bytes)}',
      );
      if (saved == false) throw StateError('Could not save avatar');
      _avatarPhoto = bytes;
      _avatar = null;
      notifyListeners();
    } finally {
      original?.dispose();
      thumbnail?.dispose();
      codec.dispose();
    }
  }

  Future<void> recoverAvatarPhoto() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final response = await ImagePicker().retrieveLostData();
      if (response.isEmpty) return;
      if (response.exception != null) throw response.exception!;
      final files = response.files;
      if (files != null && files.isNotEmpty) await setAvatarPhoto(files.first);
    } catch (_) {
      photoRecoveryError = 'Could not load photo. Please try another image.';
      notifyListeners();
    }
  }

  String? _avatar;
  String? get avatar => _avatar;

  Future<void> setAvatar(String? value) async {
    if (value != null && !avatars.containsKey(value)) {
      throw ArgumentError.value(value, 'avatar');
    }
    final saved = value == null
        ? await _preferences?.remove('profile_avatar')
        : await _preferences?.setString('profile_avatar', value);
    if (saved == false) throw StateError('Could not save avatar');
    _avatar = value;
    _avatarPhoto = null;
    notifyListeners();
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

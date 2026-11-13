import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:moneymate/main.dart';
import 'package:moneymate/home_screen.dart';
import 'package:moneymate/models/user_model.dart';

class FakePhotoPicker extends ImagePickerPlatform {
  bool fail = false;
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    if (fail) throw StateError('Picker failed');
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Avatar persists through profile edits and can be reset', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final user = UserModel(prefs);
    await user.setAvatar('Fox');
    await user.register('Aruzhan', email: 'a@example.com');
    expect(UserModel(prefs).avatar, 'Fox');
    await user.signOut();
    expect(UserModel(prefs).avatar, 'Fox');
    await expectLater(user.setAvatar('invalid'), throwsArgumentError);
    expect(user.avatar, 'Fox');
    await user.setAvatar(null);
    expect(UserModel(prefs).avatar, isNull);
  });

  test(
    'Photo is normalized, persists, survives invalid replacement and resets',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawColor(const Color(0xff00aa00), ui.BlendMode.src);
      final picture = recorder.endRecording();
      final original = await picture.toImage(800, 400);
      final data = await original.toByteData(format: ui.ImageByteFormat.png);
      final file = XFile.fromData(
        data!.buffer.asUint8List(),
        name: 'photo.png',
      );
      original.dispose();
      picture.dispose();
      final user = UserModel(prefs);
      await user.setAvatar('Fox');
      await user.setAvatarPhoto(file);
      expect(user.avatar, isNull);
      expect(user.avatarPhoto, isNotNull);
      final restored = UserModel(prefs);
      expect(restored.avatarPhoto, orderedEquals(user.avatarPhoto!));
      final codec = await ui.instantiateImageCodec(restored.avatarPhoto!);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 256);
      expect(frame.image.height, 256);
      frame.image.dispose();
      codec.dispose();
      final saved = prefs.getString('profile_avatar');
      await expectLater(
        user.setAvatarPhoto(XFile.fromData(Uint8List.fromList([1, 2, 3]))),
        throwsA(anything),
      );
      expect(prefs.getString('profile_avatar'), saved);
      expect(user.avatarPhoto, orderedEquals(restored.avatarPhoto!));
      await user.setAvatar('Cat');
      expect(UserModel(prefs).avatarPhoto, isNull);
      await user.setAvatarPhoto(file);
      await user.setAvatar(null);
      expect(UserModel(prefs).avatarPhoto, isNull);
      expect(prefs.getString('profile_avatar'), isNull);
    },
  );

  test('Corrupted stored photo falls back safely', () async {
    SharedPreferences.setMockInitialValues({
      'profile_avatar': 'photo:invalid!',
    });
    final user = UserModel(await SharedPreferences.getInstance());
    expect(user.avatarPhoto, isNull);
  });

  testWidgets(
    'Failed photo selection leaves avatar and shows a recoverable error',
    (tester) async {
      final originalPicker = ImagePickerPlatform.instance;
      final picker = FakePhotoPicker()..fail = true;
      ImagePickerPlatform.instance = picker;
      addTearDown(() => ImagePickerPlatform.instance = originalPicker);
      await tester.pumpWidget(const MoneyMateApp());
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('change-avatar')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('choose-avatar-photo')));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not load photo. Please try another image.'),
        findsOneWidget,
      );
      picker.fail = false;
      await tester.tap(find.byKey(const ValueKey('choose-avatar-photo')));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not load photo. Please try another image.'),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('choose-avatar-photo')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('avatar-Fox')));
      await tester.pumpAndSettle();
      expect(find.text('🦊'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Choose, reopen and reset avatar on a narrow phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MoneyMateApp());
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    final user = ScopedModel.of<UserModel>(
      tester.element(find.byType(HomeScreen)),
    );
    await tester.tap(find.byKey(const ValueKey('change-avatar')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('avatar-Fox')));
    await tester.pumpAndSettle();
    expect(user.avatar, 'Fox');
    expect(find.text('🦊'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('change-avatar')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('reset-avatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('reset-avatar')));
    await tester.pumpAndSettle();
    expect(user.avatar, isNull);
    expect(find.text('🦊'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

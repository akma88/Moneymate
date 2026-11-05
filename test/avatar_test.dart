import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:moneymate/main.dart';
import 'package:moneymate/home_screen.dart';
import 'package:moneymate/models/user_model.dart';

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

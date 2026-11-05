import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../app_settings.dart';
import '../models/user_model.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ScopedModel.of<UserModel>(context, rebuildOnChange: true);
    final s = AppSettings.of(context);
    return Semantics(
      button: true,
      label: s.text('Change avatar'),
      child: Tooltip(
        message: s.text('Change avatar'),
        child: InkWell(
          key: const ValueKey('change-avatar'),
          customBorder: const CircleBorder(),
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => _AvatarPicker(user: user),
          ),
          child: ExcludeSemantics(
            child: SizedBox(
              width: 88,
              height: 88,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _AvatarFace(avatar: user.avatar, name: user.name),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 15,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarFace extends StatelessWidget {
  const _AvatarFace({required this.avatar, this.name});
  final String? avatar;
  final String? name;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final emoji = UserModel.avatars[avatar];
    final initials = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first.toUpperCase())
        .join();
    return CircleAvatar(
      backgroundColor: colors.primaryContainer,
      child: emoji != null
          ? Text(emoji, style: const TextStyle(fontSize: 36))
          : initials.isNotEmpty
          ? Text(
              initials,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: colors.onPrimaryContainer,
              ),
            )
          : Icon(
              Icons.person_outline_rounded,
              size: 36,
              color: colors.onPrimaryContainer,
            ),
    );
  }
}

class _AvatarPicker extends StatefulWidget {
  const _AvatarPicker({required this.user});
  final UserModel user;
  @override
  State<_AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<_AvatarPicker> {
  bool _saving = false;
  String? _error;
  Future<void> _select(String? avatar) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.user.setAvatar(avatar);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.of(context);
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.text('Choose your avatar'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                s.text('A little more you'),
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: UserModel.avatars.keys.map((avatar) {
                  final selected = widget.user.avatar == avatar;
                  return Semantics(
                    selected: selected,
                    button: true,
                    label: s.text(avatar),
                    child: Tooltip(
                      message: s.text(avatar),
                      child: InkWell(
                        key: ValueKey('avatar-$avatar'),
                        onTap: _saving ? null : () => _select(avatar),
                        borderRadius: BorderRadius.circular(24),
                        child: ExcludeSemantics(
                          child: Container(
                            width: 72,
                            height: 72,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: selected
                                    ? colors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: _AvatarFace(avatar: avatar),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                key: const ValueKey('reset-avatar'),
                onPressed: _saving ? null : () => _select(null),
                icon: const Icon(Icons.person_outline),
                label: Text(s.text('Use default avatar')),
              ),
              if (_saving) const LinearProgressIndicator(),
              if (_error != null)
                Text(s.text(_error!), style: TextStyle(color: colors.error)),
            ],
          ),
        ),
      ),
    );
  }
}

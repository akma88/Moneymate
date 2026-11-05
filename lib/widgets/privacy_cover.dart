import 'package:flutter/material.dart';
import '../app_settings.dart';

class PrivacyCover extends StatefulWidget {
  const PrivacyCover({super.key, required this.enabled, required this.child});
  final bool enabled;
  final Widget child;
  @override
  State<PrivacyCover> createState() => _PrivacyCoverState();
}

class _PrivacyCoverState extends State<PrivacyCover>
    with WidgetsBindingObserver {
  late AppLifecycleState? _lifecycle;
  @override
  void initState() {
    super.initState();
    _lifecycle = WidgetsBinding.instance.lifecycleState;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _lifecycle = state);
  }

  @override
  Widget build(BuildContext context) {
    final covered =
        widget.enabled &&
        _lifecycle != null &&
        _lifecycle != AppLifecycleState.resumed;
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          excluding: covered,
          child: IgnorePointer(ignoring: covered, child: widget.child),
        ),
        if (covered)
          Positioned.fill(
            child: Material(
              key: const ValueKey('privacy-cover'),
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'MoneyMate',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppSettings.of(context).text('Your finances are hidden'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

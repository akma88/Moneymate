import 'package:flutter/material.dart';
import '../app_theme.dart';

/// A decorative companion that echoes the smiling coin in the brand mark.
class CoinMascot extends StatelessWidget {
  const CoinMascot({super.key, this.size = 80});
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: size * 0.08,
              bottom: size * 0.08,
              width: size * 0.84,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.violet,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: size * 0.04,
              bottom: size * 0.04,
              width: size * 0.86,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.coral,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.ink, width: 1.5),
                ),
                child: Icon(
                  Icons.sentiment_satisfied_alt_rounded,
                  size: size * 0.62,
                  color: AppTheme.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

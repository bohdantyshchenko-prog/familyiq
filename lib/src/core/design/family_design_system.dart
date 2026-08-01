import 'package:flutter/material.dart';

abstract final class FamilySpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class FamilyRadius {
  static const BorderRadius card = BorderRadius.all(Radius.circular(28));
  static const BorderRadius hero = BorderRadius.all(Radius.circular(36));
  static const BorderRadius control = BorderRadius.all(Radius.circular(18));
}

abstract final class FamilyMotion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 280);
  static const Duration emphasized = Duration(milliseconds: 420);
  static const Curve curve = Curves.easeOutCubic;
}

class PremiumSurface extends StatelessWidget {
  const PremiumSurface({required this.child, this.padding = const EdgeInsets.all(20), super.key});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: FamilyRadius.card,
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .55)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: .08),
              blurRadius: 34,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Padding(padding: padding, child: child),
      );

class AdaptiveContent extends StatelessWidget {
  const AdaptiveContent({required this.child, this.maxWidth = 1120, super.key});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
      );
}

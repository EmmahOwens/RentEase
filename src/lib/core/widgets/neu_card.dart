import 'package:flutter/material.dart';
import '../theme/neu_theme.dart';

class NeuCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? color;
  final bool isPressed;

  const NeuCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16.0,
    this.color,
    this.isPressed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: NeuTheme.getNeumorphicDecoration(
        context: context,
        isPressed: isPressed,
        radius: radius,
        color: color,
      ),
      child: child,
    );
  }
}
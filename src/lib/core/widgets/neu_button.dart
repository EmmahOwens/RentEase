import 'package:flutter/material.dart';
import '../theme/neu_theme.dart';

class NeuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isPrimary;
  final double radius;
  final EdgeInsets padding;
  final Color? color;

  const NeuButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.radius = 16.0,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 16,
    ),
    this.color,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    setState(() => _isPressed = true);
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.color ??
        (widget.isPrimary ? theme.colorScheme.primary : theme.scaffoldBackgroundColor);
    final foregroundColor = widget.isPrimary
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.primary;

    return Listener(
      onPointerDown: widget.isLoading ? null : _onPointerDown,
      onPointerUp: widget.isLoading ? null : _onPointerUp,
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding,
          decoration: NeuTheme.getNeumorphicDecoration(
            context: context,
            isPressed: _isPressed,
            radius: widget.radius,
            color: backgroundColor,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                    ),
                  )
                : DefaultTextStyle(
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                    ),
                    child: widget.child,
                  ),
          ),
        ),
      ),
    );
  }
}
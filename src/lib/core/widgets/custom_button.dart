import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MaterialButton(
      onPressed: isLoading ? null : onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOutlined 
            ? BorderSide(color: theme.colorScheme.primary)
            : BorderSide.none,
      ),
      elevation: isOutlined ? 0 : 2,
      color: isOutlined 
          ? Colors.transparent
          : backgroundColor ?? theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOutlined 
                      ? theme.colorScheme.primary
                      : Colors.white,
                ),
              ),
            )
          : Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isOutlined
                    ? theme.colorScheme.primary
                    : textColor ?? Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon; // Add icon parameter
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon, // Add to constructor
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine text color based on outline status and provided color
    final Color effectiveTextColor = isOutlined
        ? theme.colorScheme.primary
        : textColor ?? Colors.white;

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
          : Row( // Use Row to display icon and text
              mainAxisSize: MainAxisSize.min, // Prevent Row from expanding unnecessarily
              children: [
                if (icon != null) ...[ // Conditionally display icon
                  Icon(
                    icon,
                    size: 20, // Match loading indicator size
                    color: effectiveTextColor, // Use determined text color
                  ),
                  const SizedBox(width: 8), // Spacing between icon and text
                ],
                Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: effectiveTextColor, // Use determined text color
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}
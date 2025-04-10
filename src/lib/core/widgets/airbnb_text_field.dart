import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AirbnbTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final int? maxLines;
  final bool showLabel;
  final IconData? prefixIcon;
  final Widget? suffix;

  const AirbnbTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.isPassword = false,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.autofocus = false,
    this.textInputAction,
    this.onSubmitted,
    this.maxLines = 1,
    this.showLabel = true,
    this.prefixIcon,
    this.suffix,
  });

  @override
  State<AirbnbTextField> createState() => _AirbnbTextFieldState();
}

class _AirbnbTextFieldState extends State<AirbnbTextField> {
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabel && widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Focus(
          onFocusChange: (hasFocus) {
            setState(() => _isFocused = hasFocus);
          },
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscureText,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            autofocus: widget.autofocus,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onSubmitted,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.suffix,
              label: !widget.showLabel && widget.label.isNotEmpty
                  ? Text(widget.label)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/neu_theme.dart';

class NeuTextField extends StatefulWidget {
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

  const NeuTextField({
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
    this.maxLines,
  });

  @override
  State<NeuTextField> createState() => _NeuTextFieldState();
}

class _NeuTextFieldState extends State<NeuTextField> {
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Focus(
          onFocusChange: (hasFocus) {
            setState(() => _isFocused = hasFocus);
          },
          child: Container(
            decoration: NeuTheme.getNeumorphicDecoration(
              context: context,
              isPressed: _isFocused,
              radius: 12,
            ),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: InputBorder.none,
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
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Reusable form input text field for AIMS-Diabetes.
///
/// Features:
/// - Supports label, placeholder/hint text, helper text, and validation error messages.
/// - Built-in password visibility toggle when [isPassword] is true.
/// - Customizable keyboard type, action, prefix/suffix icons.
/// - Adheres to Figma input field tokens: 12px corner radius ([AppRadius.sm]), themed borders.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.controller,
    this.initialValue,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.autovalidateMode,
    this.focusNode,
  });

  final String? label;
  final String? hintText;
  final String? helperText;
  final TextEditingController? controller;
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    Widget? effectiveSuffix = widget.suffixIcon;
    if (widget.isPassword) {
      effectiveSuffix = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: colors.textSecondary,
          size: 20,
        ),
        onPressed: widget.enabled ? _toggleObscure : null,
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelStrong.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.isPassword ? _obscureText : false,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
          focusNode: widget.focusNode,
          style: AppTextStyles.bodyDefault.copyWith(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: effectiveSuffix,
            filled: true,
            fillColor: widget.enabled ? colors.bgSurfaceAlt : colors.bgSurface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

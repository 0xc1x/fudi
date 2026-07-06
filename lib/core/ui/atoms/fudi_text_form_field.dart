import 'package:flutter/material.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';

class FudiTextFormField extends StatelessWidget {
  const FudiTextFormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixText,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? prefixText;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FudiTypography.labelSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          focusNode: focusNode,
          textInputAction: maxLines == 1 ? textInputAction : null,
          onFieldSubmitted: maxLines == 1 ? onFieldSubmitted : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FudiRadius.lg),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FudiRadius.lg),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
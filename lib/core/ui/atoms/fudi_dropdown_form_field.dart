import 'package:flutter/material.dart';
import '../fudi_colors.dart';
import '../fudi_spacing.dart';
import '../fudi_typography.dart';

class FudiDropdownFormField<T> extends StatelessWidget {
  const FudiDropdownFormField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FudiTypography.labelSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FudiRadius.lg),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FudiRadius.lg),
              borderSide: const BorderSide(
                color: FudiColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
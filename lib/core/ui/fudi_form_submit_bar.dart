import 'package:flutter/material.dart';
import 'atoms/fudi_button.dart';
import 'fudi_bottom_action_bar.dart';

class FudiFormSubmitBar extends StatelessWidget {
  const FudiFormSubmitBar({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FudiBottomActionBar(
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: FudiButton(
          text: text,
          onPressed: onPressed,
          fullWidth: true,
          isLoading: isLoading,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
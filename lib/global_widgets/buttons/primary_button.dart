import 'package:flutter/material.dart';
import '../../core/values/app_constants.dart';
import '../dialogs/app_loading.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  final IconData? trailingIcon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const AppLoading(
                size: AppConstants.buttonIconSize,
                color: Colors.white,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: AppConstants.buttonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: AppConstants.paddingS),
                    Icon(trailingIcon, size: 20),
                  ]
                ],
              ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/app_constants.dart';

class OtpInput extends StatelessWidget {
  final int length;
  final Function(String)? onCompleted;
  final Function(String)? onChanged;
  final TextEditingController? controller;

  const OtpInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Style mặc định cho từng ô OTP
    final defaultPinTheme = PinTheme(
      width: AppConstants.otpWidth,
      height: AppConstants.otpHeight,
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: AppConstants.otpFontSize,
        color: AppColors.onSurface,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
    );

    // Style khi người dùng focus vào ô
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: AppColors.primaryContainer, 
        width: AppConstants.otpBorderWidth
      ),
      borderRadius: BorderRadius.circular(AppConstants.radiusL),
    );

    // Style khi đã điền số vào ô
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: AppColors.surfaceContainerHigh,
      ),
    );

    return Pinput(
      length: length,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      onCompleted: onCompleted,
      onChanged: onChanged,
      // Tự động focus vào ô đầu tiên khi mở màn hình
      autofocus: true,
      // autolisten mã SMS mặc định được pinput xử lý trong phiên bản 6.x
      // Hiệu ứng scale khi người dùng bấm
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      controller: controller,
      cursor: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: 22,
            height: 2,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}


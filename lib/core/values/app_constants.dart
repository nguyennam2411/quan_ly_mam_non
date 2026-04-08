import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // Padding & Margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 40.0;
  static const double paddingXXXL = 48.0;

  static const double horizontalPadding = paddingL;
  static const double verticalPadding = paddingM;

  // BorderRadius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusMax = 999.0;

  // Auth/Illustration specific
  static const double authIllustrationSize = 180.0;
  static const double authInnerCircleSize = 120.0;
  static const double authIllustrationIconSize = 60.0;
  static const double authIllustrationBadgeSize = 28.0;
  
  // Login & Splash logos
  static const double logoSizeLarge = 220.0;
  static const double logoSizeMedium = 160.0;
  static const double logoSizeSmall = 120.0;

  // Buttons
  static const double buttonHeight = 52.0;
  static const double buttonFontSize = 16.0;
  static const double buttonIconSize = 24.0;

  // Inputs
  static const double inputIconSize = 24.0;
  static const double inputPrefixIconPadding = 16.0;
  static const double inputMinHeight = 48.0;
  
  // OTP
  static const double otpWidth = 50.0;
  static const double otpHeight = 60.0;
  static const double otpFontSize = 24.0;
  static const double otpBorderWidth = 2.0;

  // Opacity levels
  static const double opacityLow = 0.08;
  static const double opacityMedium = 0.15;
  static const double opacityHigh = 0.35;
  static const double shadowOpacity = 0.12;

  // DashBoard
  static const double navIconSize = 24.0;
  static const double navFontSize = 12.0;
  static const double navElevation = 10.0;

  // Delays & Durations
  static const Duration splashDelay = Duration(seconds: 3);
  static const Duration timerPeriodic = Duration(seconds: 1);
  static const Duration snackbarDuration = Duration(seconds: 3);
  static const int otpCountdownSeconds = 60;

  // Spacing helper widgets
  static const Widget spacingS = SizedBox(height: paddingS);
  static const Widget spacingM = SizedBox(height: paddingM);
  static const Widget spacingL = SizedBox(height: paddingL);
  static const Widget spacingXL = SizedBox(height: paddingXL);
  static const Widget spacingXXL = SizedBox(height: paddingXXL);
  static const Widget spacingXXXL = SizedBox(height: paddingXXXL);
}

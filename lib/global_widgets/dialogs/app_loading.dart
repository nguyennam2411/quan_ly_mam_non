import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/theme/app_colors.dart';

class AppLoading extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoading({
    super.key, 
    this.size = 50.0, 
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitThreeBounce( // SpinKitCircle, SpinKitWave, SpinKitFadingCircle
        color: color ?? AppColors.primary,
        size: size,
      ),
    );
  }
}
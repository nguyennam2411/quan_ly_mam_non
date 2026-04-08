import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/app_assets.dart';
import '../../core/values/app_constants.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? errorText;
  final Function(String)? onChanged;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.errorText,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      style: const TextStyle(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: widget.hintText,
        errorText: widget.errorText,
        helperText: ' ', // Giữ chỗ 1 dòng trống bên dưới để không bị nhảy khi có lỗi
        errorMaxLines: 1,
        helperStyle: const TextStyle(fontSize: 12, height: 1.0),
        errorStyle: const TextStyle(fontSize: 12, height: 1.0, color: AppColors.error),
        prefixIcon: widget.prefixIcon != null 
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.inputPrefixIconPadding),
              child: widget.prefixIcon,
            )
          : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: AppConstants.inputMinHeight, 
          minHeight: AppConstants.inputMinHeight
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: SvgPicture.asset(
                  _obscureText ? AppAssets.icEyeClosed : AppAssets.icEyeOpen,
                  colorFilter: const ColorFilter.mode(AppColors.outline, BlendMode.srcIn),
                  width: AppConstants.inputIconSize,
                  height: AppConstants.inputIconSize,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}


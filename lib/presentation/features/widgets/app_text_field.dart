import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_riverpod/presentation/extensions/build_context_x.dart';

import '../../theme/app_theme_extension.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputType,
    this.textInputAction,
    this.textAlign = TextAlign.start,
    this.textStyle,
    this.inputFormatters,
    this.onChanged,
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final bool isPassword;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isPassword,
      obscuringCharacter: '●',
      style: textStyle,
      textInputAction: textInputAction,
      keyboardType: textInputType,
      textAlign: textAlign,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        prefixIconColor: context.color(Palette.primaryTextColor),
        suffixIcon: suffixIcon,
        suffixIconColor: context.color(Palette.primaryTextColor),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: context.color(Palette.primaryTextFieldBackground),
        errorStyle: TextStyle(
          color: Colors.red.shade500,
        ),
      ),
      validator: validator,
    );
  }
}

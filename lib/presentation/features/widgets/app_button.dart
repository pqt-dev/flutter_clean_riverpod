import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/presentation/extensions/build_context_x.dart';
import 'package:flutter_clean_riverpod/presentation/theme/app_theme_extension.dart';

import 'app_text.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.title,
    this.titleColor,
    this.backgroundColor,
    this.onPressed,
    this.width,
    this.height,
    this.padding,
    this.shape,
  });

  final String title;
  final Color? titleColor;
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final OutlinedBorder? shape;

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      shape: shape,
      backgroundColor: backgroundColor ?? context.color(Palette.primaryButtonBackground),
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: 24.0,
          ),
    ),
    child: AppText(
      text: title,
      maxLines: 1,
      color: titleColor ?? context.color(Palette.primaryButtonText),
    ),
  );
}

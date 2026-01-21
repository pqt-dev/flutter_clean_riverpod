import 'package:flutter/material.dart';

import 'app_text.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.title,
    required this.titleColor,
    required this.backgroundColor,
    this.onTap,
    this.width,
    this.height,
    this.padding,
    this.shape,
  });

  final String title;
  final Color? titleColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final OutlinedBorder? shape;

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      shape: shape,
      backgroundColor: backgroundColor,
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: 24.0,
          ),
    ),
    child: AppText(
      text: title,
      maxLines: 1,
      color: titleColor,
    ),
  );
}

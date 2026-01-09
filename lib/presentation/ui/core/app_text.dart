import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/presentation/common/build_context_ext.dart';

import '../../theme/app_theme_extension.dart';
class AppText extends StatelessWidget {
  const AppText({
    super.key,
    required this.text,
    this.color,
    this.weight,
    this.size = 14.0,
    this.overflow,
    this.style,
    this.maxLines,
    this.height,
    this.textAlign,
  });

  final String text;
  final Color? color;
  final FontWeight? weight;
  final double size;
  final TextOverflow? overflow;
  final TextStyle? style;
  final int? maxLines;
  final double? height;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? context.color(Palette.primaryTextColor);
    return Text(
      text,
      style: style ??
          TextStyle(
            color: color,
            fontSize: size,
            fontWeight: weight,
            overflow: overflow,
            height: height,
          ),
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }
}

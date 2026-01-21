import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_text.dart';

class AppBarView extends StatelessWidget implements PreferredSizeWidget {
  const AppBarView({
    super.key,
    this.title,
    this.onBack,
    this.actions,
    this.leading,
    this.canBack = true,
    this.widthIconLeading,
    this.heightIconLeading,
    this.backgroundColor,
    this.titleColor,
  });

  final String? title;
  final Function? onBack;
  final List<Widget>? actions;
  final bool canBack;
  final Widget? leading;
  final double? widthIconLeading;
  final double? heightIconLeading;
  final Color? backgroundColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    Widget? leadingIcon = leading != null
        ? Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: leading,
          )
        : (canBack
              ? IconButton(
                  onPressed: () {
                    if (onBack != null) {
                      onBack!();
                    } else {
                      context.pop();
                    }
                  },
                  icon: Icon(
                    Platform.isAndroid ? Icons.arrow_back_outlined : Icons.arrow_back_ios_outlined,
                  ),
                )
              : const SizedBox());
    return AppBar(
      scrolledUnderElevation: 0,
      title: title != null
          ? AppText(
              text: title!,
              size: 16.0,
              weight: .w600,
              color: titleColor,
            )
          : null,
      leading: leadingIcon,
      centerTitle: true,
      actions: actions,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

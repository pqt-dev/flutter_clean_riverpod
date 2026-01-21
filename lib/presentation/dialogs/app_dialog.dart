import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../extensions/build_context_x.dart';
import '../features/widgets/app_button.dart';
import '../features/widgets/app_text.dart';
import '../theme/app_theme_extension.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onCancel,
    this.onConfirm,

    /// If [canPopBySystem] is set to false,
    /// the back navigation gesture (like the system back button or swipe gesture)
    /// will be disabled.
    this.canPopBySystem = true,
    super.key,
  });

  final String? title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool canPopBySystem;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPopBySystem,
      child: Dialog(
        child: Column(
          mainAxisSize: .min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.color(Palette.primaryBackground),
                borderRadius: const BorderRadius.all(
                  Radius.circular(16.0),
                ),
              ),
              child: _buildBody,
            ),
          ],
        ),
      ),
    );
  }

  Widget get _buildBody {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Builder(
              builder: (context) {
                return AppText(
                  text: title!,
                  color: context.color(Palette.primaryTextColor),
                  textAlign: TextAlign.center,
                );
              },
            ),
          Builder(
            builder: (context) {
              return AppText(
                text: message,
                color: context.color(Palette.primaryTextColor),
                textAlign: TextAlign.center,
              );
            },
          ),
          _buildActions,
        ],
      ),
    );
  }

  Widget get _buildActions {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 16.0,
      children: [
        if (onCancel != null)
          Builder(
            builder: (context) {
              return AppButton(
                title: cancelText ?? LocaleKeys.label_cancel.tr(),
                titleColor: context.color(Palette.primaryButtonText),
                backgroundColor: context.color(Palette.primaryButtonBackground),
                padding: EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                onTap: () => onCancel?.call(),
              );
            },
          ),
        if (onConfirm != null)
          Builder(
            builder: (context) {
              return AppButton(
                title: confirmText ?? LocaleKeys.label_ok.tr(),
                titleColor: context.color(Palette.primaryButtonText),
                backgroundColor: context.color(Palette.primaryButtonBackground),
                padding: EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                onTap: () {
                  if (onConfirm != null) {
                    onConfirm!();
                  }
                },
              );
            },
          ),
      ],
    );
  }
}

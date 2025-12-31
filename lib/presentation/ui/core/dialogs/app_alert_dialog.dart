import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/presentation/common/build_context_ext.dart';
import 'package:flutter_clean_riverpod/presentation/ui/core/app_text.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../theme/app_theme_extension.dart';
import '../app_button.dart';

class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onCancel,
    this.onConfirm,
    required this.enableBackNav,
    super.key,
  });

  final String? title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool enableBackNav;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: enableBackNav,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: context.color(AppPalette.primaryTextFieldBackground),
              borderRadius: const BorderRadius.all(
                Radius.circular(16.0),
              ),
            ),
            child: _buildBody,
          ),
        ],
      ),
    );
  }

  Widget get _buildBody {
    return Builder(
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: title != null,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
                child: AppText(
                  text: title ?? '-',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: AppText(
                text: message,
                textAlign: TextAlign.center,
              ),
            ),
            _buildActions,
          ],
        );
      },
    );
  }

  Widget get _buildActions {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 30.0,
            horizontal: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: onCancel != null,
                child: AppButton(
                  width: 100.0,
                  title: cancelText ?? LocaleKeys.label_cancel.tr(),
                  titleColor: context.color(AppPalette.secondaryButtonTitle),
                  backgroundColor: context.color(AppPalette.secondaryColor),
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  onTap: () {
                    if (onCancel != null) {
                      onCancel!();
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Visibility(
                visible: onConfirm != null,
                child: AppButton(
                  width: 100.0,
                  title: confirmText ?? LocaleKeys.label_ok.tr(),
                  titleColor: Colors.white,
                  backgroundColor: context.color(AppPalette.mainColor),
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  onTap: () {
                    if (onConfirm != null) {
                      onConfirm!();
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

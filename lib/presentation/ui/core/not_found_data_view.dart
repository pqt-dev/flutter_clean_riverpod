import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/presentation/ui/core/app_text.dart';

import '../../../generated/locale_keys.g.dart';

class NotFoundDataView extends StatelessWidget {
  const NotFoundDataView({
    super.key,
    this.textColor,
  });

  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.not_interested,
            size: 50.0,
          ),
          const SizedBox(height: 10.0),
          AppText(
            text: LocaleKeys.not_found_data.tr(),
          ),
        ],
      ),
    );
  }
}

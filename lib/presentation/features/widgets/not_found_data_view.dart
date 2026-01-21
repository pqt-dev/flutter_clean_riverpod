import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/generated/assets.gen.dart';

import '../../../generated/locale_keys.g.dart';
import 'app_text.dart';

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
          Assets.images.pngs.oops.image(
            width: 100.0,
          ),
          const SizedBox(height: 10.0),
          AppText(
            text: LocaleKeys.not_found_data.tr(),
            size: 16.0,
          ),
        ],
      ),
    );
  }
}

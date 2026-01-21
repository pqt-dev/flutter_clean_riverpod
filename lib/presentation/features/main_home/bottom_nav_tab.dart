import 'package:easy_localization/easy_localization.dart';

import '../../../generated/locale_keys.g.dart';

enum BottomNavTab {
  feed,
  search,
  favourite,
  setting,
}

extension BottomNavTabExt on BottomNavTab {
  String get title {
    switch (this) {
      case BottomNavTab.feed:
        return LocaleKeys.home_tab_feed.tr();
      case BottomNavTab.search:
        return LocaleKeys.home_tab_search.tr();
      case BottomNavTab.favourite:
        return LocaleKeys.home_tab_favourite.tr();
      case BottomNavTab.setting:
        return LocaleKeys.home_tab_setting.tr();
    }
  }
}

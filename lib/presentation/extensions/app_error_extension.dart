import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_clean_riverpod/domain/core/app_error.dart';
import 'package:flutter_clean_riverpod/generated/locale_keys.g.dart';

extension AppErrorL10n on AppError {
  String get localizedMessage => switch (this) {
    NetworkError() => LocaleKeys.error_network.tr(),
    ServerError() => LocaleKeys.error_server.tr(),
    AuthError() => LocaleKeys.error_auth.tr(),
    ParsingError() => LocaleKeys.error_parsing.tr(),
    UnexpectedError() => LocaleKeys.error_unexpected.tr(),
  };
}

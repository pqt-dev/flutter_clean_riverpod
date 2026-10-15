import 'package:flutter_clean_riverpod/domain/core/app_error.dart';
import 'package:flutter_clean_riverpod/generated/locale_keys.g.dart';
import 'package:flutter_clean_riverpod/presentation/extensions/app_error_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // easy_localization is not initialized in unit tests, so `.tr()` returns the key.
  test('localizedMessage maps each AppError to its l10n key', () {
    expect(const NetworkError().localizedMessage, LocaleKeys.error_network);
    expect(const ServerError().localizedMessage, LocaleKeys.error_server);
    expect(const AuthError().localizedMessage, LocaleKeys.error_auth);
    expect(const ParsingError().localizedMessage, LocaleKeys.error_parsing);
    expect(
      const UnexpectedError().localizedMessage,
      LocaleKeys.error_unexpected,
    );
  });
}

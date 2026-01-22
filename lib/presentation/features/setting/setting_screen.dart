import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.setting.tr()),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButton<Locale>(
            value: context.locale,
            onChanged: (Locale? newLocale) {
              if (newLocale != null) {
                context.setLocale(newLocale);
              }
            },
            items: context.supportedLocales.map((locale) {
              return DropdownMenuItem<Locale>(
                value: locale,
                child: Text(locale.languageCode.toUpperCase()),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

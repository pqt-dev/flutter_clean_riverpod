import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_riverpod/presentation/common/build_context_ext.dart';
import 'package:flutter_clean_riverpod/presentation/router/app_routes.dart';

import '../../../generated/locale_keys.g.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.shellPush(AppRoutes.detailSetting, parent: AppRoutes.setting),
      ),
      appBar: AppBar(
        title: Text(LocaleKeys.home_tab_setting.tr()),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                LocaleKeys.hello.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButton<Locale>(
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
            ],
          ),
        ),
      ),
    );
  }
}

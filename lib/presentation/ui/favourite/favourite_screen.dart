import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/theme_mode_viewmodel.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: ThemeSwitcher(),
    );
  }
}

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewmodel = ref.read(themeModeViewmodelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text("Theme Switcher")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => viewmodel.setTheme(ThemeMode.light),
              child: Text("Light Theme"),
            ),
            ElevatedButton(
              onPressed: () => viewmodel.setTheme(ThemeMode.dark),
              child: Text("Dark Theme"),
            ),
            ElevatedButton(
              onPressed: () => viewmodel.setTheme(ThemeMode.system),
              child: Text("System Theme"),
            ),
          ],
        ),
      ),
    );
  }
}

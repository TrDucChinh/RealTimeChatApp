import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/localization/app_localizations.dart';
import '../cubits/theme_cubit.dart';
import '../cubits/locale_cubit.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('title')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              child: Text(AppLocalizations.of(context).translate('change_theme')),
            ),
            ElevatedButton(
              onPressed: () => context.read<LocaleCubit>().changeLocale('vi'),
              child: const Text('🇻🇳 Tiếng Việt'),
            ),
            ElevatedButton(
              onPressed: () => context.read<LocaleCubit>().changeLocale('en'),
              child: const Text('🇺🇸 English'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/localization/app_localizations_delegate.dart';
import 'cubits/theme_cubit.dart';
import 'cubits/locale_cubit.dart';
import 'screens/test_multi_lang_multi_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: theme,
              locale: locale,
              supportedLocales: const [Locale('en'), Locale('vi')],
              localizationsDelegates: const [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate, // Bổ sung delegate này
              ],
              home: const HomeScreen(),
            );
          },
        );
      },
    );
  }
}

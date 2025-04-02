import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'config/localization/app_localizations_delegate.dart';
import 'config/router/app_router.dart';
import 'cubits/theme_cubit.dart';
import 'cubits/locale_cubit.dart';

class MyApp extends StatelessWidget { 
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocBuilder<ThemeCubit, ThemeData>(
          builder: (context, theme) {
            return BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp.router(
                  routerConfig: AppRouter.router,
                  debugShowCheckedModeBanner: false,
                  theme: theme,
                  locale: locale,
                  supportedLocales: const [Locale('en'), Locale('vi')],
                  localizationsDelegates: const [
                    AppLocalizationsDelegate(),
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate, 
                  ],
                  // home: const HomeScreen(),
                  // home: const ChatsScreen(),
                  // home: const MainScreen(),
                );
              },
            );
          },
        );
      },
    );
  }
}

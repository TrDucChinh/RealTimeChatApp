import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/bottom_nav_cubit.dart';
import 'cubits/theme_cubit.dart';
import 'cubits/locale_cubit.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeCubit = ThemeCubit();
  await themeCubit.loadTheme();

  final localeCubit = LocaleCubit();
  await localeCubit.loadLocale();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => themeCubit),
        BlocProvider(create: (_) => localeCubit),
        BlocProvider(create: (_) => BottomNavCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

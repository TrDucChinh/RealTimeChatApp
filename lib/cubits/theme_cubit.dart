import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/storage_service.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(ThemeData.light());

  Future<void> loadTheme() async {
    final bool isDark = await StorageService.getTheme();
    emit(isDark ? ThemeData.dark() : ThemeData.light());
  }

  Future<void> toggleTheme() async {
    final bool isDark = state == ThemeData.dark();
    await StorageService.saveTheme(!isDark);
    emit(isDark ? ThemeData.light() : ThemeData.dark());
  }
}

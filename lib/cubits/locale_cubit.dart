import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/storage_service.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  Future<void> loadLocale() async {
    final String langCode = await StorageService.getLanguage();
    emit(Locale(langCode));
  }

  Future<void> changeLocale(String languageCode) async {
    await StorageService.saveLanguage(languageCode);
    emit(Locale(languageCode));
  }
}

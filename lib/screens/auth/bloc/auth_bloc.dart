import 'dart:convert';

import 'package:chat_app_ttcs/screens/auth/bloc/auth_event.dart';
import 'package:chat_app_ttcs/services/network_service.dart';
import 'package:chat_app_ttcs/services/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final NetworkService _networkService;
  AuthBloc(
    this._networkService,
  ) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final loginBody = {
        'email': event.email,
        'password': event.password,
      };
      final response = await _networkService.post(
        '/auth/login',
        body: loginBody,
      );
      print('Response status login: ${response.statusCode}');
      if (response.statusCode != 200) {
        emit(AuthError('Login failed'));
        return;
      }
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (token == null) {
        emit(AuthError('Invalid token'));
        return;
      }

      await StorageService.saveToken(token);
      emit(AuthSuccess(token));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

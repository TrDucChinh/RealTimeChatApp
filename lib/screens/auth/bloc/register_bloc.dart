import 'package:chat_app_ttcs/screens/auth/bloc/register_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/network_service.dart';
import 'register_event.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final NetworkService _networkService;
  RegisterBloc(this._networkService) : super(RegisterInitial()) {
    on<SignUpEvent>(_onSignUp);
  }

  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<RegisterState> emit,
  ) async {
    try {
      emit(RegisterLoading());
      final registerBody = {
        'username': event.username,
        'email': event.email,
        'password': event.password,
      };
      final response = await _networkService.post(
        '/auth/register',
        body: registerBody,
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode != 201) {
        print('Registration failed: ${response.body}');
        emit(RegisterError('Registration failed'));
        return;
      }
      final data = response.body;
      emit(RegisterSuccess(data));
    } catch (e) {
      emit(RegisterError(e.toString()));
    }
  }
}

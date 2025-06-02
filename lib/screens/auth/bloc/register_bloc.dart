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
        'email': event.email,
        'password': event.password,
        'name': event.name,
      };
      final response = await _networkService.post(
        '/auth/register',
        body: registerBody,
      );
      if (response.statusCode != 200) {
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

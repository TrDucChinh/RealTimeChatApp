import 'package:equatable/equatable.dart';

sealed class RegisterBlocEvent extends Equatable {
  const RegisterBlocEvent();

  @override
  List<Object> get props => [];
}

abstract class RegisterEvent {}

class SignUpEvent extends RegisterEvent {
  final String email;
  final String password;
  final String username;

  SignUpEvent({
    required this.email,
    required this.password,
    required this.username,
  });

  List<Object> get props => [email, password, username];
}

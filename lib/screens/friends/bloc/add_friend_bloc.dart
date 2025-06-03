import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app_ttcs/models/user_model.dart';
import 'package:chat_app_ttcs/services/network_service.dart';
import 'package:chat_app_ttcs/sample_token.dart';
import 'dart:convert';

// Events
abstract class AddFriendEvent {}

class LoadUsers extends AddFriendEvent {
  final String? searchQuery;
  LoadUsers({this.searchQuery});
}

// States
abstract class AddFriendState {}

class AddFriendInitial extends AddFriendState {}

class AddFriendLoading extends AddFriendState {}

class AddFriendLoaded extends AddFriendState {
  final List<UserModel> users;
  AddFriendLoaded(this.users);
}

class AddFriendError extends AddFriendState {
  final String message;
  AddFriendError(this.message);
}

// Bloc
class AddFriendBloc extends Bloc<AddFriendEvent, AddFriendState> {
  final NetworkService _networkService;

  AddFriendBloc({required String token})
      : _networkService = NetworkService(
          baseUrl: baseUrl2,
          token: token,
        ),
        super(AddFriendInitial()) {
    on<LoadUsers>(_onLoadUsers);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<AddFriendState> emit,
  ) async {
    try {
      emit(AddFriendLoading());
      final endpoint = event.searchQuery != null && event.searchQuery!.isNotEmpty
          ? '/users/search?query=${event.searchQuery}'
          : '/users';
      
      final response = await _networkService.get(endpoint);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('users') && data['users'] is List) {
          final List<dynamic> usersData = data['users'];
          final users = usersData.map((json) => UserModel.fromJson(json)).toList();
          emit(AddFriendLoaded(users));
        } else {
          emit(AddFriendError('Invalid response format'));
        }
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to load users';
        emit(AddFriendError(errorMessage));
      }
    } catch (e) {
      emit(AddFriendError(e.toString()));
    }
  }
} 
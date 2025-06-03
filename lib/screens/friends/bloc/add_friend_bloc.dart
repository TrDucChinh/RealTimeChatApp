import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app_ttcs/models/user_model.dart';
import 'package:chat_app_ttcs/services/network_service.dart';
import 'package:chat_app_ttcs/sample_token.dart';
import 'package:chat_app_ttcs/common/helper/helper.dart';
import 'dart:convert';

// Events
abstract class AddFriendEvent {}

class LoadUsers extends AddFriendEvent {
  final String? searchQuery;
  final int? page;
  final int? limit;
  LoadUsers({this.searchQuery, this.page, this.limit});
}

// States
abstract class AddFriendState {}

class AddFriendInitial extends AddFriendState {}

class AddFriendLoading extends AddFriendState {}

class AddFriendLoaded extends AddFriendState {
  final List<UserModel> users;
  final int totalPages;
  final int currentPage;
  AddFriendLoaded(
    this.users, {
    required this.totalPages,
    required this.currentPage,
  });
}

class AddFriendError extends AddFriendState {
  final String message;
  AddFriendError(this.message);
}

// Bloc
class AddFriendBloc extends Bloc<AddFriendEvent, AddFriendState> {
  final NetworkService _networkService;
  final String _currentUserId;
  int _currentPage = 1;
  static const int _pageSize = 10;
  List<String> _friendIds = [];

  AddFriendBloc({required String token})
      : _networkService = NetworkService(
          baseUrl: baseUrl2,
          token: token,
        ),
        _currentUserId = Helper.getUserIdFromToken(token),
        super(AddFriendInitial()) {
    on<LoadUsers>(_onLoadUsers);
  }

  Future<void> _loadFriends() async {
    try {
      final response = await _networkService.get('/users/friends');
      print('Friends API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> friendsData = json.decode(response.body);
        _friendIds = friendsData
            .map((friend) {
              if (friend is Map<String, dynamic> && friend.containsKey('_id')) {
                return friend['_id'] as String;
              }
              return '';
            })
            .where((id) => id.isNotEmpty)
            .toList();
        print('Final friend IDs: $_friendIds');
      } else {
        print('Failed to load friends. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading friends: $e');
    }
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<AddFriendState> emit,
  ) async {
    try {
      if (event.page == null) {
        emit(AddFriendLoading());
        _currentPage = 1;
        await _loadFriends();
      }

      final page = event.page ?? _currentPage;
      final limit = event.limit ?? _pageSize;

      String endpoint;
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        endpoint =
            '/users/search?query=${event.searchQuery}&page=$page&limit=$limit';
      } else {
        endpoint = '/users?page=$page&limit=$limit';
      }

      final response = await _networkService.get(endpoint);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Users API Response: $data'); // Debug full response
        if (data.containsKey('users') && data['users'] is List) {
          final List<dynamic> usersData = data['users'];
          final pagination = data['pagination'] as Map<String, dynamic>;

          // Filter out current user and existing friends
          final users = usersData
              .where((userData) {
                final userId = userData['_id'] as String;
                final isNotCurrentUser = userId != _currentUserId;
                final isNotFriend = !_friendIds.contains(userId);
                print('Checking user: $userId'); // Debug user ID
                print(
                    'Current friend IDs: $_friendIds'); // Debug current friend IDs
                print('Is friend: ${!isNotFriend}'); // Debug friend status
                return isNotCurrentUser && isNotFriend;
              })
              .map((json) => UserModel.fromJson(json))
              .toList();

          if (event.page == null) {
            emit(
              AddFriendLoaded(
                users,
                totalPages: pagination['totalPages'] as int,
                currentPage: pagination['page'] as int,
              ),
            );
          } else {
            final currentState = state as AddFriendLoaded;
            final updatedUsers = [...currentState.users, ...users];
            emit(
              AddFriendLoaded(
                updatedUsers,
                totalPages: pagination['totalPages'] as int,
                currentPage: pagination['page'] as int,
              ),
            );
          }
          _currentPage = page + 1;
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

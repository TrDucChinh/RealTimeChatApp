import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app_ttcs/models/user_model.dart';
import 'package:chat_app_ttcs/services/network_service.dart';
import 'package:chat_app_ttcs/sample_token.dart';
import 'dart:convert';

import 'create_group_event.dart';
import 'create_group_state.dart';

class CreateGroupBloc extends Bloc<CreateGroupEvent, CreateGroupState> {
  final NetworkService _networkService;
  int _currentPage = 1;
  static const int _pageSize = 10;

  CreateGroupBloc({required String token})
      : _networkService = NetworkService(
          baseUrl: baseUrl2,
          token: token,
        ),
        super(CreateGroupInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<CreateGroup>(_onCreateGroup);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<CreateGroupState> emit,
  ) async {
    try {
      if (event.page == null) {
        print('Initial load of users');
        emit(CreateGroupLoading());
        _currentPage = 1;
      }

      final page = event.page ?? _currentPage;
      final limit = event.limit ?? _pageSize;
      
      String endpoint;
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        endpoint = '/users?search?query=${event.searchQuery}&page=$page&limit=$limit';
      } else {
        endpoint = '/users?page=$page&limit=$limit';
      }
      
      print('Loading users from endpoint: $endpoint');
      final response = await _networkService.get(endpoint);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data.containsKey('users') && data['users'] is List) {
          final List<dynamic> usersData = data['users'];
          final pagination = data['pagination'] as Map<String, dynamic>;
          
          final users = usersData
              .map((json) => UserModel.fromJson(json))
              .toList();

          print('Loaded ${users.length} users');

          if (event.page == null) {
            print('Emitting initial CreateGroupLoaded state');
            emit(
              CreateGroupLoaded(
                users: users,
                totalPages: pagination['totalPages'] as int,
                currentPage: pagination['page'] as int,
              ),
            );
          } else {
            final currentState = state as CreateGroupLoaded;
            final updatedUsers = [...currentState.users, ...users];
            print('Emitting updated CreateGroupLoaded state with ${updatedUsers.length} users');
            emit(
              CreateGroupLoaded(
                users: updatedUsers,
                totalPages: pagination['totalPages'] as int,
                currentPage: pagination['page'] as int,
              ),
            );
          }
          _currentPage = page + 1;
        } else {
          print('Invalid response format: $data');
          emit(CreateGroupError('Invalid response format'));
        }
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to load users';
        print('Error loading users: $errorMessage');
        emit(CreateGroupError(errorMessage));
      }
    } catch (e) {
      print('Error in _onLoadUsers: $e');
      emit(CreateGroupError(e.toString()));
    }
  }

  Future<void> _onCreateGroup(
    CreateGroup event,
    Emitter<CreateGroupState> emit,
  ) async {
    try {
      emit(CreateGroupLoading());
      final response = await _networkService.post(
        '/conversations',
        body: {
          'name': event.name,
          'participants': event.members.map((e) => e.id).toList(),
          'type': 'group',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data == null) {
          throw Exception('Invalid response data');
        }

        final groupId = data['id'] ?? data['_id'];
        if (groupId == null) {
          throw Exception('Group ID not found in response');
        }

        emit(CreateGroupSuccess(
          groupId: groupId.toString(),
          name: event.name,
          members: event.members,
        ));
      } else {
        final errorData = json.decode(response.body);
        emit(CreateGroupError(
          errorData['message'] ?? 'Failed to create group',
        ));
      }
    } catch (e) {
      print('Error in _onCreateGroup: $e');
      emit(CreateGroupError(e.toString()));
    }
  }
} 
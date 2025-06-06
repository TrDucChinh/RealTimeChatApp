import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app_ttcs/models/user_model.dart';
import 'package:chat_app_ttcs/services/network_service.dart';
import 'package:chat_app_ttcs/sample_token.dart';
import 'package:chat_app_ttcs/common/helper/helper.dart';
import 'dart:convert';

import '../../../models/friend_request.dart';
import 'add_friend_event.dart';
import 'add_friend_state.dart';

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
    on<LoadFriendRequests>(_onLoadFriendRequests);
    on<LoadFriends>(_onLoadFriends);
    on<AcceptFriendRequest>(_onAcceptFriendRequest);
    on<RejectFriendRequest>(_onRejectFriendRequest);
    on<SendFriendRequest>(_onSendFriendRequest);
  }

  Future<void> _loadFriends() async {
    try {
      final response = await _networkService.get('/users/friends');
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
      }
    } catch (e) {
      print('Error loading friends: $e');
    }
  }

  Future<void> _onLoadFriendRequests(
    LoadFriendRequests event,
    Emitter<AddFriendState> emit,
  ) async {
    try {
      print('Loading friend requests for user: $_currentUserId');
      final response = await _networkService.get('/users/friend-requests/$_currentUserId');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> requestsData = json.decode(response.body);
        print('Parsed requests data: $requestsData');
        
        final requests = requestsData
            .map((request) {
              final sender = request['sender'];
              print('Processing sender data: $sender');
              return FriendRequest.fromJson({
                '_id': request['_id'],
                'sender': {
                  '_id': sender['_id'],
                  'username': sender['username'],
                  'email': sender['email'],
                  'avatarUrl': sender['avatar'] != null && sender['avatar']['url'] != null 
                      ? sender['avatar']['url'] 
                      : 'https://ui-avatars.com/api/?name=${sender['username']}',
                  'status': 'offline',
                  'lastSeen': DateTime.now().toIso8601String(),
                },
                'status': request['status'],
                'createdAt': request['createdAt'],
              });
            })
            .toList();
        
        print('Processed friend requests: ${requests.length}');

        if (state is AddFriendLoaded) {
          final currentState = state as AddFriendLoaded;
          print('Current state is AddFriendLoaded, updating with ${requests.length} requests');
          emit(AddFriendLoaded(
            currentState.users,
            totalPages: currentState.totalPages,
            currentPage: currentState.currentPage,
            friendRequests: requests,
            friends: currentState.friends,
            notification: null,
          ),);
        } else {
          print('Current state is not AddFriendLoaded: ${state.runtimeType}');
        }
      }
    } catch (e, stackTrace) {
      print('Error loading friend requests: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _onAcceptFriendRequest(
    AcceptFriendRequest event,
    Emitter<AddFriendState> emit,
  ) async {
    try {
      print('Accepting friend request: ${event.requestId}');
      final response = await _networkService.put(
        '/users/friend-request/${event.requestId}/accept',
        body: {
          'userId': _currentUserId,
        },
      );
      print('Accept response status: ${response.statusCode}');
      print('Accept response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String senderId = responseData['sender'];

        final conversationResponse = await _networkService.post(
          '/conversations',
          body: {
            'participants': [_currentUserId, senderId],
            'type': 'group',
          },
        );

        if (conversationResponse.statusCode == 201) {
          print('Conversation created successfully');
        } else {
          print('Failed to create conversation: ${conversationResponse.body}');
        }

        if (state is AddFriendLoaded) {
          final currentState = state as AddFriendLoaded;
          emit(AddFriendLoaded(
            currentState.users,
            totalPages: currentState.totalPages,
            currentPage: currentState.currentPage,
            friendRequests: currentState.friendRequests,
            friends: currentState.friends,
            notification: 'Friend request accepted successfully',
          ),);
        }
        add(LoadFriendRequests());
        add(LoadUsers());
        add(LoadFriends());
      }
    } catch (e) {
      print('Error accepting friend request: $e');
      if (state is AddFriendLoaded) {
        final currentState = state as AddFriendLoaded;
        emit(AddFriendLoaded(
          currentState.users,
          totalPages: currentState.totalPages,
          currentPage: currentState.currentPage,
          friendRequests: currentState.friendRequests,
          friends: currentState.friends,
          notification: 'Failed to accept friend request',
        ),);
      }
    }
  }

  Future<void> _onRejectFriendRequest(
    RejectFriendRequest event,
    Emitter<AddFriendState> emit,
  ) async {
    try {
      print('Rejecting friend request: ${event.requestId}');
      final response = await _networkService.put(
        '/users/friend-request/${event.requestId}/reject',
        body: {
          'userId': _currentUserId,
        },
      );
      print('Reject response status: ${response.statusCode}');
      print('Reject response body: ${response.body}');
      
      if (response.statusCode == 200) {
        if (state is AddFriendLoaded) {
          final currentState = state as AddFriendLoaded;
          emit(AddFriendLoaded(
            currentState.users,
            totalPages: currentState.totalPages,
            currentPage: currentState.currentPage,
            friendRequests: currentState.friendRequests,
            friends: currentState.friends,
            notification: 'Friend request rejected successfully',
          ),);
        }
        add(LoadFriendRequests());
        add(LoadFriends());
      }
    } catch (e) {
      print('Error rejecting friend request: $e');
      if (state is AddFriendLoaded) {
        final currentState = state as AddFriendLoaded;
        emit(AddFriendLoaded(
          currentState.users,
          totalPages: currentState.totalPages,
          currentPage: currentState.currentPage,
          friendRequests: currentState.friendRequests,
          friends: currentState.friends,
          notification: 'Failed to reject friend request',
        ),);
      }
    }
  }

  Future<void> _onLoadFriends(
    LoadFriends event,
    Emitter<AddFriendState> emit,
  ) async {
    try {
      // First get the list of friend IDs
      final response = await _networkService.get('/users/friends');
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

        // Then get the details of each friend
        final List<UserModel> friends = [];
        for (final friendId in _friendIds) {
          final friendResponse = await _networkService.get('/users/$friendId');
          if (friendResponse.statusCode == 200) {
            final friendData = json.decode(friendResponse.body);
            friends.add(UserModel.fromJson(friendData));
          }
        }

        if (state is AddFriendLoaded) {
          final currentState = state as AddFriendLoaded;
          emit(AddFriendLoaded(
            currentState.users,
            totalPages: currentState.totalPages,
            currentPage: currentState.currentPage,
            friendRequests: currentState.friendRequests,
            friends: friends,
            notification: null,
          ),);
        } else {
          emit(AddFriendLoaded(
            [],
            totalPages: 1,
            currentPage: 1,
            friends: friends,
            notification: null,
          ),);
        }
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
        print('Initial load of users');
        emit(AddFriendLoading());
        _currentPage = 1;
        await _loadFriends();
      }

      final page = event.page ?? _currentPage;
      final limit = event.limit ?? _pageSize;
      
      String endpoint;
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        endpoint = '/users?search=${event.searchQuery}&page=$page&limit=$limit';
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
              .where((userData) {
                final userId = userData['_id'] as String;
                final isNotCurrentUser = userId != _currentUserId;
                final isNotFriend = !_friendIds.contains(userId);
                return isNotCurrentUser && isNotFriend;
              })
              .map((json) => UserModel.fromJson(json))
              .toList();

          print('Loaded ${users.length} users');

          if (event.page == null) {
            print('Emitting initial AddFriendLoaded state');
            emit(
              AddFriendLoaded(
                users,
                totalPages: pagination['totalPages'] as int,
                currentPage: pagination['page'] as int,
                friendRequests: [],
                friends: [],
                notification: null,
              ),
            );
            print('Loading friend requests after initial users load');
            add(LoadFriendRequests());
          } else {
            final currentState = state as AddFriendLoaded;
            final updatedUsers = [...currentState.users, ...users];
            print('Emitting updated AddFriendLoaded state with ${updatedUsers.length} users');
            emit(
              AddFriendLoaded(
                updatedUsers,
                totalPages: pagination['totalPages'] as int,
                currentPage: pagination['page'] as int,
                friendRequests: currentState.friendRequests,
                friends: currentState.friends,
                notification: null,
              ),
            );
          }
          _currentPage = page + 1;
        } else {
          print('Invalid response format: $data');
          emit(AddFriendError('Invalid response format'));
        }
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to load users';
        print('Error loading users: $errorMessage');
        emit(AddFriendError(errorMessage));
      }
    } catch (e) {
      print('Error in _onLoadUsers: $e');
      emit(AddFriendError(e.toString()));
    }
  }

  Future<void> _onSendFriendRequest(
    SendFriendRequest event,
    Emitter<AddFriendState> emit,
  ) async {
    try {
      print('Sending friend request to: ${event.receiverId}');
      final response = await _networkService.post(
        '/users/friend-request',
        body: {
          'senderId': _currentUserId,
          'receiverId': event.receiverId,
        },
      );
      print('Send friend request response status: ${response.statusCode}');
      print('Send friend request response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Get current state
        if (state is AddFriendLoaded) {
          final currentState = state as AddFriendLoaded;
          // Remove the user from the list since we sent them a request
          final updatedUsers = currentState.users.where((user) => user.id != event.receiverId).toList();
          
          emit(AddFriendLoaded(
            updatedUsers,
            totalPages: currentState.totalPages,
            currentPage: currentState.currentPage,
            friendRequests: currentState.friendRequests,
            friends: currentState.friends,
            notification: 'Friend request sent successfully',
          ),);
        }
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to send friend request';
        // Emit error state but keep current state
        if (state is AddFriendLoaded) {
          final currentState = state as AddFriendLoaded;
          emit(AddFriendLoaded(
            currentState.users,
            totalPages: currentState.totalPages,
            currentPage: currentState.currentPage,
            friendRequests: currentState.friendRequests,
            friends: currentState.friends,
            notification: errorMessage,
          ),);
        } else {
          emit(AddFriendError(errorMessage));
        }
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to send friend request';
        emit(AddFriendError(errorMessage));
      }
    } catch (e) {
      print('Error sending friend request: $e');
      emit(AddFriendError('Failed to send friend request: ${e.toString()}'));
    }
  }
}

import '../../../models/friend_request.dart';
import '../../../models/user_model.dart';

abstract class AddFriendState {}

class AddFriendInitial extends AddFriendState {}

class AddFriendLoading extends AddFriendState {}

class AddFriendLoaded extends AddFriendState {
  final List<UserModel> users;
  final List<FriendRequest> friendRequests;
  final List<UserModel> friends;
  final int totalPages;
  final int currentPage;
  final String? notification;
  AddFriendLoaded(
    this.users, {
    required this.totalPages,
    required this.currentPage,
    this.friendRequests = const [],
    this.friends = const [],
    this.notification,
  });
}

class AddFriendError extends AddFriendState {
  final String message;
  AddFriendError(this.message);
}
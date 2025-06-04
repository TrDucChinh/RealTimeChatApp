// States
import '../../../models/user_model.dart';

abstract class CreateGroupState {}

class CreateGroupInitial extends CreateGroupState {}

class CreateGroupLoading extends CreateGroupState {}

class CreateGroupLoaded extends CreateGroupState {
  final List<UserModel> users;
  final int totalPages;
  final int currentPage;
  final String? notification;

  CreateGroupLoaded({
    required this.users,
    required this.totalPages,
    required this.currentPage,
    this.notification,
  });
}

class CreateGroupError extends CreateGroupState {
  final String message;
  CreateGroupError(this.message);
}

class CreateGroupSuccess extends CreateGroupState {
  final String groupId;
  final String name;
  final List<UserModel> members;
  CreateGroupSuccess({
    required this.groupId,
    required this.name,
    required this.members,
  });
}

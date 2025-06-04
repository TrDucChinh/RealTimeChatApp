// Events
import '../../../models/user_model.dart';

abstract class CreateGroupEvent {}

class LoadUsers extends CreateGroupEvent {
  final String? searchQuery;
  final int? page;
  final int? limit;
  LoadUsers({this.searchQuery, this.page, this.limit});
}

class CreateGroup extends CreateGroupEvent {
  final String name;
  final List<UserModel> members;
  CreateGroup({required this.name, required this.members});
}
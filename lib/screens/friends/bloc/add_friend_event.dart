abstract class AddFriendEvent {}

class LoadUsers extends AddFriendEvent {
  final String? searchQuery;
  final int? page;
  final int? limit;
  LoadUsers({this.searchQuery, this.page, this.limit});
}

class LoadFriendRequests extends AddFriendEvent {}

class LoadFriends extends AddFriendEvent {}

class AcceptFriendRequest extends AddFriendEvent {
  final String requestId;
  AcceptFriendRequest(this.requestId);
}

class RejectFriendRequest extends AddFriendEvent {
  final String requestId;
  RejectFriendRequest(this.requestId);
}

class SendFriendRequest extends AddFriendEvent {
  final String receiverId;
  SendFriendRequest(this.receiverId);
}